# tuonghoangthien-attendance-api — Backend FastAPI

Hệ thống Web API phục vụ ứng dụng **Chấm công nhân viên**, được xây dựng bằng **FastAPI (Python)**, sử dụng cơ sở dữ liệu **Microsoft SQL Server 2022** kết nối qua SQLAlchemy & PyODBC, hỗ trợ xác thực hai bước (Mật khẩu + OTP email) và JWT.

---

## 📌 Công Nghệ Sử Dụng
- **Framework**: FastAPI (Python 3.10+)
- **Server**: Uvicorn (ASGI)
- **Cơ sở dữ liệu**: Microsoft SQL Server 2022 (quản lý qua SSMS)
- **ORM / Driver**: SQLAlchemy 2.0+ & `pyodbc` (ODBC Driver 18 for SQL Server)
- **Bảo mật & Xác thực**: `PyJWT` (Access Token 15 phút, Refresh Token 7 ngày), `bcrypt` (mã hóa mật khẩu), Email OTP (hỗ trợ SMTP hoặc chế độ in terminal)
- **Validation**: Pydantic v2 & Pydantic-Settings

---

## 📁 Cấu Trúc Thư Mục Nhánh `backend`
```text
├── app/                     # Mã nguồn chính API
│   ├── main.py              # Điểm khởi động FastAPI & cấu hình CORS, routers
│   ├── core.py              # Cấu hình Settings, kết nối CSDL, JWT & hàm bảo mật
│   ├── models.py            # Khai báo bảng CSDL SQLAlchemy (User, Department, Shift, Employee, Attendance, OtpCode...)
│   ├── schemas.py           # Định nghĩa cấu trúc dữ liệu Pydantic request / response
│   └── routers/             # Phân nhóm API endpoints
│       ├── auth.py          # Đăng ký, đăng nhập 2 bước, xác thực OTP, JWT refresh
│       ├── attendance.py    # Check-in, check-out, buddy check, lịch sử cá nhân
│       └── admin.py         # Quản trị phòng ban, ca làm việc, nhân viên, phân quyền
├── migrations/              # Script migration SQL
│   └── add_face_encoding.sql# Script cập nhật trường dữ liệu nhận diện khuôn mặt
├── .env.example             # File cấu hình biến môi trường mẫu an toàn
├── .gitignore               # Loại trừ môi trường ảo (.venv), __pycache__ và file bí mật (.env)
├── requirements.txt         # Danh sách thư viện Python cần cài đặt
├── seed.py                  # Script khởi tạo bảng CSDL và tài khoản admin mặc định
└── README.md                # Tài liệu hướng dẫn cài đặt và vận hành
```

---

## 🛠️ Hướng Dẫn Cài Đặt & Chạy Từng Bước

### 1. Yêu Cầu Môi Trường
- [Python 3.10+](https://www.python.org/downloads/)
- Microsoft SQL Server 2022 & SQL Server Management Studio (SSMS 20/22)
- [Microsoft ODBC Driver 18 for SQL Server](https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server)

### 2. Khởi Tạo Cơ Sở Dữ Liệu
Mở SSMS, kết nối tới SQL Server của bạn và thực thi lệnh:
```sql
CREATE DATABASE db_tuonghoangthien_attendance;
```

### 3. Cài Đặt Thư Viện Python
Mở terminal PowerShell tại thư mục của nhánh backend:
```powershell
# Tạo môi trường ảo
py -m venv .venv

# Kích hoạt môi trường ảo
.venv\Scripts\Activate.ps1

# Cài đặt các gói phụ thuộc
pip install -r requirements.txt
```

### 4. Cấu Hình Biến Môi Trường (`.env`)
Tạo file cấu hình `.env` từ file mẫu:
```powershell
Copy-Item .env.example .env
```
Mở file `.env` và cập nhật thông tin đăng nhập SQL Server của bạn:
```env
DB_SERVER=localhost
DB_NAME=db_tuonghoangthien_attendance
DB_USER=sa
DB_PASSWORD=Mật_khẩu_SQL_của_bạn
DB_DRIVER=ODBC Driver 18 for SQL Server
```
*(Nếu dùng Windows Authentication, chỉ cần để trống `DB_USER` và `DB_PASSWORD`)*

### 5. Khởi Tạo Dữ Liệu Mẫu
Chạy script tự động tạo các bảng và chèn dữ liệu mẫu (admin, phòng ban, ca làm việc, nhân viên):
```powershell
python seed.py
```
**Tài khoản mẫu mặc định:**
- **Quản trị viên (Admin)**: `tuonghoangthien` / `thien@134` (hoặc `admin` / `Admin@123`)
- **Nhân viên (Employee)**: `an`, `binh`, `chau` / `Employee@123`
- **Khách hàng (Customer)**: `khach` / `Customer@123`

### 6. Chạy Máy Chủ API
```powershell
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```
- API Server sẽ lắng nghe tại: `http://127.0.0.1:8000`
- **Tài liệu Swagger UI tương tác trực quan**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- Tài liệu ReDoc: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

---

## 📡 Danh Sách API Endpoints Chính

| Phân hệ | Phương thức | Endpoint | Mô tả |
| :--- | :--- | :--- | :--- |
| **Auth** | `POST` | `/auth/register` | Đăng ký tài khoản mới |
| | `POST` | `/auth/verify-email` | Xác thực email đăng ký |
| | `POST` | `/auth/login` | Đăng nhập bước 1 (nhận OTP) |
| | `POST` | `/auth/verify-otp` | Xác thực OTP & cấp phát JWT |
| | `POST` | `/auth/refresh` | Làm mới access token |
| | `GET` | `/auth/me` | Lấy thông tin user hiện tại |
| **Attendance** | `POST` | `/attendance/check-in` | Điểm danh vào ca |
| | `POST` | `/attendance/check-out` | Điểm danh ra ca |
| | `POST` | `/attendance/buddy-confirm` | Xác nhận chấm công chéo |
| | `GET` | `/attendance/me` | Xem lịch sử chấm công |
| **Admin** | `GET/POST/PUT/DELETE` | `/admin/departments` | Quản lý phòng ban |
| | `GET/POST/PUT/DELETE` | `/admin/shifts` | Quản lý ca làm việc |
| | `GET/POST/PUT/DELETE` | `/admin/employees` | Quản lý nhân viên |
| | `GET/POST/PUT/DELETE` | `/attendance/records` | Quản trị bản ghi chấm công |
| | `PATCH` | `/admin/users/{id}/role` | Phân quyền tài khoản |