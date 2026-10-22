"""Dữ liệu vào và ra của API (Pydantic schemas)."""
from datetime import date, datetime, time

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class RegisterIn(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(min_length=8)
    confirm_password: str


class VerifyEmailIn(BaseModel):
    email: EmailStr
    code: str = Field(min_length=6, max_length=6)


class LoginIn(BaseModel):
    username: str
    password: str


class OtpIn(BaseModel):
    challenge_token: str
    otp: str = Field(min_length=6, max_length=6)


class RefreshIn(BaseModel):
    refresh_token: str


class ChallengeOut(BaseModel):
    challenge_token: str
    message: str


class TokenOut(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    role: str


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    username: str
    email: EmailStr
    role: str
    is_active: bool
    is_verified: bool


class RoleIn(BaseModel):
    role: str = Field(pattern="^(admin|employee|customer)$")


class DepartmentIn(BaseModel):
    name: str = Field(min_length=1, max_length=100)


class DepartmentOut(DepartmentIn):
    model_config = ConfigDict(from_attributes=True)
    id: int


class ShiftIn(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    start_time: time
    end_time: time
    is_active: bool = True


class ShiftOut(ShiftIn):
    model_config = ConfigDict(from_attributes=True)
    id: int


class EmployeeIn(BaseModel):
    full_name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    phone: str | None = None
    department_id: int
    user_id: int | None = None


class EmployeeOut(EmployeeIn):
    model_config = ConfigDict(from_attributes=True)
    id: int


class AttendanceIn(BaseModel):
    employee_id: int
    check_in: datetime
    check_out: datetime | None = None


class CheckInIn(BaseModel):
    buddy_employee_id: int | None = None
    buddy_method: str | None = Field(default=None, pattern="^(qr|bluetooth)$")


class BuddyConfirmIn(BaseModel):
    employee_id: int
    buddy_employee_id: int | None = None
    method: str = Field(pattern="^(qr|bluetooth)$")


class AttendanceOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    employee_id: int
    work_date: date
    check_in: datetime
    check_out: datetime | None
    is_late: bool
    is_early_leave: bool
    buddy_confirmed_by: int | None = None
    is_suspicious: bool
    buddy_method: str | None = None


class FaceRegisterIn(BaseModel):
    face_data: str = Field(description="Ảnh khuôn mặt mã hóa base64")


class FaceLoginIn(BaseModel):
    username: str
    face_data: str = Field(description="Ảnh khuôn mặt mã hóa base64")
