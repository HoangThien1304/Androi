"""Cấu hình, kết nối SQL Server 2022, mật khẩu, mã OTP, JWT và phân quyền."""
import datetime as dt
import hashlib
import secrets
import smtplib
from email.message import EmailMessage
from functools import lru_cache
from urllib.parse import quote_plus

import bcrypt
import jwt
from fastapi import Depends, HTTPException
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic_settings import BaseSettings, SettingsConfigDict
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Session, sessionmaker


class Settings(BaseSettings):
    """Đọc cấu hình bảo mật trực tiếp từ file .env."""
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    # SQL Server Database Configuration
    db_server: str = r"(localdb)\MSSQLLocalDB"
    db_name: str = "db_tuonghoangthien_attendance"
    db_user: str = ""
    db_password: str = ""
    db_driver: str = "ODBC Driver 18 for SQL Server"

    # JWT Authentication Security Secret & Lifetimes
    jwt_secret: str = "tuonghoangthien-super-secret-key-2026-attendance-api"
    access_token_minutes: int = 15
    refresh_token_days: int = 7
    otp_minutes: int = 5
    otp_max_attempts: int = 3
    lock_minutes: int = 5

    # SMTP Configuration (để trống = chế độ demo in mã ra terminal)
    smtp_host: str = ""
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    mail_from: str = "thientuong316@gmail.com"

    # Default Seed Admin Credentials (đọc từ file .env)
    admin_username: str = "tuonghoangthien"
    admin_password: str = "thien@134"
    admin_email: str = "thientuong316@gmail.com"

    @property
    def database_url(self) -> str:
        """Chuỗi kết nối SQL Server tự động nhận diện Windows Auth hoặc SA Auth."""
        if self.db_user and self.db_password:
            auth_part = f"UID={self.db_user};PWD={self.db_password};"
        else:
            auth_part = "Trusted_Connection=yes;"
        odbc = (f"DRIVER={{{self.db_driver}}};SERVER={self.db_server};"
                f"DATABASE={self.db_name};{auth_part}"
                "TrustServerCertificate=yes")
        return "mssql+pyodbc:///?odbc_connect=" + quote_plus(odbc)


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
engine = create_engine(settings.database_url, pool_pre_ping=True)
SessionLocal = sessionmaker(bind=engine, autoflush=False)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_or_404(db: Session, model, item_id: int):
    obj = db.get(model, item_id)
    if obj is None:
        raise HTTPException(404, f"Không tìm thấy {model.__tablename__} #{item_id}")
    return obj


def utcnow() -> dt.datetime:
    return dt.datetime.now(dt.timezone.utc).replace(tzinfo=None)


# ---------- Mật khẩu và mã xác thực ----------
def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password: str, hashed: str) -> bool:
    return bcrypt.checkpw(password.encode(), hashed.encode())


def new_code() -> str:
    """Mã 6 chữ số ngẫu nhiên."""
    return f"{secrets.randbelow(1_000_000):06d}"


def hash_code(code: str) -> str:
    return hashlib.sha256(code.encode()).hexdigest()


def send_email(to: str, subject: str, body: str) -> None:
    if not settings.smtp_host:
        print(f"[EMAIL -> {to}] {subject}: {body}")
        return
    msg = EmailMessage()
    msg["Subject"], msg["From"], msg["To"] = subject, settings.mail_from, to
    msg.set_content(body)
    with smtplib.SMTP(settings.smtp_host, settings.smtp_port) as smtp:
        smtp.starttls()
        if settings.smtp_user:
            smtp.login(settings.smtp_user, settings.smtp_password)
        smtp.send_message(msg)


# ---------- JWT ----------
def create_token(sub: str, kind: str, lifetime: dt.timedelta) -> str:
    now = utcnow()
    payload = {"sub": sub, "type": kind, "iat": now, "exp": now + lifetime}
    return jwt.encode(payload, settings.jwt_secret, algorithm="HS256")


def decode_token(token: str, kind: str) -> dict:
    try:
        data = jwt.decode(token, settings.jwt_secret, algorithms=["HS256"])
    except jwt.PyJWTError:
        raise HTTPException(401, "Token không hợp lệ hoặc đã hết hạn")
    if data.get("type") != kind:
        raise HTTPException(401, "Sai loại token")
    return data


bearer_scheme = HTTPBearer()


def get_current_user(cred: HTTPAuthorizationCredentials = Depends(bearer_scheme),
                     db: Session = Depends(get_db)):
    from .models import User
    data = decode_token(cred.credentials, "access")
    user = db.get(User, int(data["sub"]))
    if user is None or not user.is_active:
        raise HTTPException(401, "Tài khoản không tồn tại hoặc đã bị khóa")
    return user


def require_roles(*roles: str):
    """Chỉ cho phép các vai trò được liệt kê. Kiểm tra ở backend trên từng API."""
    def checker(user=Depends(get_current_user)):
        if user.role not in roles:
            raise HTTPException(403, "Bạn không có quyền thực hiện thao tác này")
        return user
    return checker
