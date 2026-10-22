
"""API đăng ký, xác thực email, đăng nhập OTP, JWT và nhận diện khuôn mặt."""

import base64
import binascii
import datetime as dt
import json

import cv2
import numpy as np

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session

from ..core import (
    create_token,
    decode_token,
    get_current_user,
    get_db,
    hash_code,
    hash_password,
    new_code,
    send_email,
    settings,
    utcnow,
    verify_password,
)
from ..models import User
from ..schemas import (
    ChallengeOut,
    FaceLoginIn,
    FaceRegisterIn,
    LoginIn,
    OtpIn,
    RefreshIn,
    RegisterIn,
    TokenOut,
    UserOut,
    VerifyEmailIn,
)

router = APIRouter(prefix="/auth", tags=["Xác thực"])

FACE_MODEL = "Facenet512"
FACE_COSINE_DISTANCE_THRESHOLD = 0.30


def _extract_face_embedding(face_data: str) -> list[float]:
    """Đọc ảnh Base64 và trích xuất embedding của đúng một khuôn mặt."""
    if not face_data or len(face_data) < 100:
        raise HTTPException(400, "Dữ liệu khuôn mặt không hợp lệ")

    encoded = (
        face_data.split(",", 1)[1]
        if face_data.startswith("data:image/") and "," in face_data
        else face_data
    )

    try:
        image_bytes = base64.b64decode(encoded, validate=True)
    except (binascii.Error, ValueError) as exc:
        raise HTTPException(400, "Dữ liệu ảnh Base64 không hợp lệ") from exc

    image = cv2.imdecode(
        np.frombuffer(image_bytes, dtype=np.uint8),
        cv2.IMREAD_COLOR,
    )
    if image is None:
        raise HTTPException(400, "Không đọc được ảnh")

    try:
        from deepface import DeepFace

        results = DeepFace.represent(
            img_path=image,
            model_name=FACE_MODEL,
            detector_backend="opencv",
            enforce_detection=True,
            align=True,
        )
    except ValueError as exc:
        raise HTTPException(400, "Không phát hiện được khuôn mặt rõ ràng") from exc
    except Exception as exc:
        raise HTTPException(
            503,
            "Dịch vụ nhận diện khuôn mặt chưa sẵn sàng. Hãy kiểm tra log API.",
        ) from exc

    if not isinstance(results, list) or len(results) != 1:
        raise HTTPException(400, "Ảnh phải có đúng một khuôn mặt")

    embedding = results[0].get("embedding")
    if not isinstance(embedding, list) or not embedding:
        raise HTTPException(503, "Không tạo được embedding khuôn mặt")

    try:
        values = [float(v) for v in embedding]
    except (TypeError, ValueError) as exc:
        raise HTTPException(503, "Embedding khuôn mặt không hợp lệ") from exc

    if not np.isfinite(values).all():
        raise HTTPException(400, "Dữ liệu khuôn mặt không hợp lệ")

    return values


def _cosine_distance(first: list[float], second: list[float]) -> float:
    a = np.asarray(first, dtype=np.float64)
    b = np.asarray(second, dtype=np.float64)

    if a.shape != b.shape or a.ndim != 1:
        raise HTTPException(
            400,
            "Dữ liệu khuôn mặt đã lưu không tương thích; hãy đăng ký lại",
        )

    denominator = float(np.linalg.norm(a) * np.linalg.norm(b))
    if denominator == 0:
        raise HTTPException(400, "Embedding khuôn mặt không hợp lệ")

    return float(1.0 - np.dot(a, b) / denominator)


def _issue_tokens(user: User) -> TokenOut:
    return TokenOut(
        access_token=create_token(
            str(user.id),
            "access",
            dt.timedelta(minutes=settings.access_token_minutes),
        ),
        refresh_token=create_token(
            str(user.id),
            "refresh",
            dt.timedelta(days=settings.refresh_token_days),
        ),
        role=user.role,
    )


def _check_account(user: User) -> None:
    if not user.is_verified:
        raise HTTPException(403, "Tài khoản chưa xác thực email")
    if not user.is_active:
        raise HTTPException(403, "Tài khoản đã bị khóa")
    if user.locked_until and user.locked_until > utcnow():
        raise HTTPException(423, "Tài khoản đang bị khóa tạm thời")


@router.post("/register")
def register(body: RegisterIn, db: Session = Depends(get_db)):
    """Tạo tài khoản và gửi mã xác thực email."""
    if body.password != body.confirm_password:
        raise HTTPException(400, "Mật khẩu xác nhận không khớp")

    existing = db.query(User).filter(
        or_(
            User.username == body.username,
            User.email == str(body.email),
            )
    ).first()

    if existing:
        if existing.username == body.username:
            raise HTTPException(409, "Tên đăng nhập đã tồn tại")
        raise HTTPException(409, "Email đã được sử dụng")

    code = new_code()
    user = User(
        username=body.username,
        email=str(body.email),
        password_hash=hash_password(body.password),
        role="customer",
        is_verified=False,
        is_active=True,
        verify_code_hash=hash_code(code),
        otp_attempts=0,
    )

    db.add(user)
    db.commit()

    send_email(
        user.email,
        "Mã xác thực tài khoản",
        f"Mã xác thực email của bạn là: {code}",
    )
    return {"message": "Đăng ký thành công. Hãy kiểm tra email để xác thực."}


@router.post("/verify-email")
def verify_email(body: VerifyEmailIn, db: Session = Depends(get_db)):
    """Xác thực email bằng mã 6 chữ số."""
    user = db.query(User).filter(User.email == str(body.email)).first()

    if not user:
        raise HTTPException(404, "Không tìm thấy tài khoản")
    if user.is_verified:
        return {"message": "Email đã được xác thực"}
    if not user.verify_code_hash or hash_code(body.code) != user.verify_code_hash:
        raise HTTPException(400, "Mã xác thực không đúng")

    user.is_verified = True
    user.verify_code_hash = None
    db.commit()
    return {"message": "Xác thực email thành công"}


@router.post("/login", response_model=ChallengeOut)
def login(body: LoginIn, db: Session = Depends(get_db)):
    """Kiểm tra mật khẩu và gửi OTP cho bước đăng nhập thứ hai."""
    user = db.query(User).filter(User.username == body.username).first()

    if not user or not verify_password(body.password, user.password_hash):
        raise HTTPException(401, "Tên đăng nhập hoặc mật khẩu không đúng")

    _check_account(user)

    code = new_code()
    user.otp_hash = hash_code(code)
    user.otp_expires_at = utcnow() + dt.timedelta(minutes=settings.otp_minutes)
    user.otp_attempts = 0
    db.commit()

    send_email(
        user.email,
        "Mã OTP đăng nhập",
        f"Mã OTP của bạn là: {code}. Mã có hiệu lực trong "
        f"{settings.otp_minutes} phút.",
    )

    challenge = create_token(
        str(user.id),
        "challenge",
        dt.timedelta(minutes=settings.otp_minutes),
    )
    return ChallengeOut(
        challenge_token=challenge,
        message="Mã OTP đã được gửi. Hãy xác thực để hoàn tất đăng nhập.",
    )


@router.post("/verify-otp", response_model=TokenOut)
def verify_otp(body: OtpIn, db: Session = Depends(get_db)):
    """Xác thực OTP và cấp access/refresh token."""
    data = decode_token(body.challenge_token, "challenge")

    try:
        user_id = int(data["sub"])
    except (KeyError, TypeError, ValueError) as exc:
        raise HTTPException(401, "Challenge token không hợp lệ") from exc

    user = db.get(User, user_id)
    if not user:
        raise HTTPException(401, "Tài khoản không tồn tại")

    _check_account(user)

    if user.locked_until and user.locked_until > utcnow():
        raise HTTPException(423, "Tài khoản đang bị khóa tạm thời")

    if not user.otp_hash or not user.otp_expires_at:
        raise HTTPException(400, "Không có OTP đang chờ xác thực")

    if user.otp_expires_at <= utcnow():
        user.otp_hash = None
        user.otp_expires_at = None
        db.commit()
        raise HTTPException(400, "OTP đã hết hạn. Hãy đăng nhập lại.")

    if hash_code(body.otp) != user.otp_hash:
        user.otp_attempts = (user.otp_attempts or 0) + 1

        if user.otp_attempts >= settings.otp_max_attempts:
            user.locked_until = utcnow() + dt.timedelta(
                minutes=settings.lock_minutes
            )
            user.otp_hash = None
            user.otp_expires_at = None
            db.commit()
            raise HTTPException(
                423,
                "Nhập sai OTP quá số lần cho phép. Tài khoản bị khóa tạm thời.",
            )

        db.commit()
        raise HTTPException(400, "OTP không đúng")

    user.otp_hash = None
    user.otp_expires_at = None
    user.otp_attempts = 0
    db.commit()

    return _issue_tokens(user)


@router.post("/refresh", response_model=TokenOut)
def refresh_token(body: RefreshIn, db: Session = Depends(get_db)):
    """Đổi refresh token lấy cặp token mới."""
    data = decode_token(body.refresh_token, "refresh")

    try:
        user_id = int(data["sub"])
    except (KeyError, TypeError, ValueError) as exc:
        raise HTTPException(401, "Refresh token không hợp lệ") from exc

    user = db.get(User, user_id)
    if not user or not user.is_active:
        raise HTTPException(401, "Tài khoản không tồn tại hoặc đã bị khóa")
    if not user.is_verified:
        raise HTTPException(403, "Tài khoản chưa xác thực email")

    return _issue_tokens(user)


@router.get("/me", response_model=UserOut)
def get_me(user: User = Depends(get_current_user)):
    """Lấy thông tin tài khoản hiện tại."""
    return user


@router.post("/face-register")
def face_register(
        body: FaceRegisterIn,
        user: User = Depends(get_current_user),
        db: Session = Depends(get_db),
):
    """Đăng ký embedding khuôn mặt cho tài khoản hiện tại."""
    _check_account(user)
    embedding = _extract_face_embedding(body.face_data)
    user.face_encoding = json.dumps(embedding)
    db.commit()

    return {"message": "Đăng ký khuôn mặt thành công"}


@router.post("/face-login", response_model=TokenOut)
def face_login(body: FaceLoginIn, db: Session = Depends(get_db)):
    """Đăng nhập bằng cách so sánh embedding khuôn mặt."""
    user = db.query(User).filter(User.username == body.username).first()

    if not user:
        raise HTTPException(401, "Tên đăng nhập hoặc mật khẩu không đúng")

    _check_account(user)

    if not user.face_encoding:
        raise HTTPException(400, "Tài khoản chưa đăng ký khuôn mặt")

    try:
        saved_embedding = json.loads(user.face_encoding)
        if not isinstance(saved_embedding, list):
            raise ValueError("Invalid embedding")
    except (json.JSONDecodeError, TypeError, ValueError) as exc:
        raise HTTPException(
            400,
            "Dữ liệu khuôn mặt đã lưu không hợp lệ; hãy đăng ký lại",
        ) from exc

    current_embedding = _extract_face_embedding(body.face_data)
    distance = _cosine_distance(saved_embedding, current_embedding)

    if distance > FACE_COSINE_DISTANCE_THRESHOLD:
        raise HTTPException(401, "Khuôn mặt không khớp với dữ liệu đã đăng ký")

    return _issue_tokens(user)
