"""Tạo bảng, dữ liệu mẫu và tài khoản admin mặc định. Chạy: python seed.py"""
from datetime import time

from app.core import Base, SessionLocal, engine, hash_password, settings
from app.models import Department, Employee, Shift, User


def main() -> None:
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        if db.query(User).filter_by(username=settings.admin_username).first():
            print("Dữ liệu mẫu đã có trong cơ sở dữ liệu db_tuonghoangthien_attendance, bỏ qua.")
            return

        db.add(User(username=settings.admin_username, email=settings.admin_email,
                    password_hash=hash_password(settings.admin_password),
                    role="admin", is_verified=True))
        it = Department(name="Phòng IT")
        hr = Department(name="Nhân sự")
        db.add_all([it, hr])
        db.add(Shift(name="Ca hành chính", start_time=time(8, 0), end_time=time(17, 0), is_active=True))
        db.flush()

        samples = [("Nguyễn Văn An", "an", it), ("Trần Thị Bình", "binh", it), ("Lê Minh Châu", "chau", hr)]
        for full_name, username, dept in samples:
            user = User(username=username, email=f"{username}@example.com",
                        password_hash=hash_password("Employee@123"), role="employee", is_verified=True)
            db.add(user)
            db.flush()
            db.add(Employee(full_name=full_name, email=user.email,
                            department_id=dept.id, user_id=user.id))

        db.add(User(username="khach", email="khach@example.com",
                    password_hash=hash_password("Customer@123"), role="customer", is_verified=True))
        db.commit()
    finally:
        db.close()

    print("Đã tạo dữ liệu mẫu thành công cho db_tuonghoangthien_attendance:")
    print(f"  Admin:       {settings.admin_username} / {settings.admin_password}")
    print("  Nhân viên:   an / Employee@123 (tương tự binh, chau)")
    print("  Khách hàng:  khach / Customer@123")


if __name__ == "__main__":
    main()
