"""Các bảng trong cơ sở dữ liệu SQL Server db_tuonghoangthien_attendance."""
import datetime as dt

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Integer, String, Time
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .core import Base


class Department(Base):
    __tablename__ = "departments"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100), unique=True)
    employees = relationship("Employee", back_populates="department")


class Shift(Base):
    __tablename__ = "shifts"
    id: Mapped[int] = mapped_column(primary_key=True)
    name: Mapped[str] = mapped_column(String(100))
    start_time: Mapped[dt.time] = mapped_column(Time)
    end_time: Mapped[dt.time] = mapped_column(Time)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True)
    username: Mapped[str] = mapped_column(String(50), unique=True)
    email: Mapped[str] = mapped_column(String(120), unique=True)
    password_hash: Mapped[str] = mapped_column(String(100))
    role: Mapped[str] = mapped_column(String(20), default="customer")  # admin | employee | customer
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    verify_code_hash: Mapped[str | None] = mapped_column(String(64))
    otp_hash: Mapped[str | None] = mapped_column(String(64))
    otp_expires_at: Mapped[dt.datetime | None] = mapped_column(DateTime)
    otp_attempts: Mapped[int] = mapped_column(Integer, default=0)
    locked_until: Mapped[dt.datetime | None] = mapped_column(DateTime)
    face_encoding: Mapped[str | None] = mapped_column(String(None), nullable=True)
    employee = relationship("Employee", back_populates="user", uselist=False)


class Employee(Base):
    __tablename__ = "employees"
    id: Mapped[int] = mapped_column(primary_key=True)
    full_name: Mapped[str] = mapped_column(String(100))
    email: Mapped[str] = mapped_column(String(120), unique=True)
    phone: Mapped[str | None] = mapped_column(String(20))
    department_id: Mapped[int] = mapped_column(ForeignKey("departments.id"))
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), unique=True)
    department = relationship("Department", back_populates="employees")
    user = relationship("User", back_populates="employee")


class AttendanceRecord(Base):
    __tablename__ = "attendance_records"
    id: Mapped[int] = mapped_column(primary_key=True)
    employee_id: Mapped[int] = mapped_column(ForeignKey("employees.id"))
    work_date: Mapped[dt.date] = mapped_column(Date, index=True)
    check_in: Mapped[dt.datetime] = mapped_column(DateTime)
    check_out: Mapped[dt.datetime | None] = mapped_column(DateTime)
    is_late: Mapped[bool] = mapped_column(Boolean, default=False)
    is_early_leave: Mapped[bool] = mapped_column(Boolean, default=False)
    buddy_confirmed_by: Mapped[int | None] = mapped_column(ForeignKey("employees.id"), nullable=True)
    is_suspicious: Mapped[bool] = mapped_column(Boolean, default=True)
    buddy_method: Mapped[str | None] = mapped_column(String(20), nullable=True)
