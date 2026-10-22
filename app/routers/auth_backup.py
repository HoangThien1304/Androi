"""Đăng ký, xác thực email, đăng nhập hai bước (mật khẩu + OTP), làm mới token JWT."""
import base64
import binascii
import datetime as dt
import json

import cv2
import numpy as np

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session

from ..core import (create_token, decode_token, get_current_user, get_db, hash_code,
                    hash_password, new_code, send_email, settings, utcnow, verify_password)
from ..models import User
from ..schemas import (ChallengeOut, FaceLoginIn, FaceRegisterIn, LoginIn, OtpIn, RefreshIn,
                       RegisterIn, TokenOut, UserOut, VerifyEmailIn)

router = APIRouter(prefix="/auth", tags=["Xác thực"])


FACE_MODEL = "Facenet512"
# Ngưỡng cosine distance tham khảo cho FaceNet512; cần hiệu chỉnh bằng dữ liệu thực tế.
FACE_COSINE_DISTANCE_THRESHOLD = 0.30


def _extract_face_embedding(face_data: str) -> list[float]:
    """Giải mã ảnh Base64 và tạo embedding cho đúng một khuôn mặt."""
    if not face_data or len(face_data) < 100:
        raise HTTPException(400, "Dữ liệu khuôn mặt không hợp lệ")

    # Chấp nhận cả Base64 thuần và dạng data:image/...;base64,...
    encoded = face_data.split(",", 1)[1] if face_data.startswith("data:image/") and "," in face_data else face_data
    try:
        image_bytes = base64.b64decode(encoded, validate=True)
    except (binascii.Error, ValueError) as exc:
        raise HTTPException(400, "Dữ liệu ảnh Base64 không hợp lệ") from exc

    image_array = np.frombuffer(image_bytes, dtype=np.uint8)
    image = cv2.imdecode(image_array, cv2.IMREAD_COLOR)
    if image is None:
        raise HTTPException(400, "Không đọc được ảnh khuôn mặt")

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
        raise HTTPException(400, "Không phát hiện được khuôn mặt rõ ràng trong ảnh") from exc
    except HTTPException:
        raise
    except Exception as exc:
        # Không trả chi tiết nội bộ/model path về client.
        raise HTTPException(
            503,
            "Dịch vụ nhận diện khuôn mặt chưa sẵn sàng. Kiểm tra log API để biết chi tiết.",
        ) from exc

    if not isinstance(results, list) or len(results) != 1:
        raise HTTPException(400, "Ảnh phải có đúng một khuôn mặt")

    embedding = results[0].get("embedding")
    if not isinstance(embedding, list) or not embedding:
        raise HTTPException(503, "Không tạo được embedding khuôn mặt")

    try:
        values = [float(value) for value in embedding]
    except (TypeError, ValueError) as exc:
        raise HTTPException(503, "Embedding khuôn mặt không hợp lệ") from exc

    if not all(np.isfinite(values)):
        raise HTTPException(400, "Dữ liệu khuôn mặt không hợp lệ")
    return values


def _cosine_distance(first: list[float], second: list[float]) -> float:
    a = np.asarray(first, dtype=np.float64)
    b = np.asarray(second, dtype=np.float64)
    if a.shape != b.shape or a.ndim != 1:
        raise HTTPException(400, "Dữ liệu khuôn mặt đã lưu không tương thích; hãy đăng ký lại")
    denominator = float(np.linalg.norm(a) * np.linalg.norm(b))
    if denominator == 0:
        raise HTTPException(400, "Embedding khuôn mặt không hợp lệ; hãy đăng ký lại")
    return float(1.0 - np.dot(a, b) / denominator)


def _issue_tokens(user: User) -> TokenOut:
    sub = str(user.id)
    return TokenOut(
        access_token=create_token(
            sub,
            "access",
            dt.timedelta(minutes=settings.access_token_minutes),
        ),
        refresh_token=create_token(
            sub,
            "refresh",
            dt.timedelta(days=settings.refresh_token_days),
        ),
        role=user.role,
    )