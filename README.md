# Hệ thống Chấm công Nhân viên

Dự án gồm hai thành phần độc lập:

- **Frontend:** Ứng dụng Flutter hỗ trợ Android và Windows Desktop.
- **Backend:** REST API xây dựng bằng FastAPI, Python và SQL Server.

## Công nghệ sử dụng

### Frontend
- Flutter và Dart.
- Provider để quản lý trạng thái.
- HTTP để gọi API.
- Shared Preferences để lưu trữ cục bộ.
- Các thư viện quét mã, nhận diện khuôn mặt và xác thực sinh trắc học theo cấu hình dự án.

### Backend
- Python 3.10+.
- FastAPI và Uvicorn.
- Microsoft SQL Server.
- SQLAlchemy và PyODBC.
- JWT, bcrypt và xác thực OTP qua email theo cấu hình dự án.

## Cấu trúc repository

Repository có hai nhánh:

| Nhánh | Nội dung |
|---|---|
| `frontend` | Mã nguồn ứng dụng Flutter |
| `backend` | Mã nguồn API FastAPI |

## Hướng dẫn chạy Frontend

Yêu cầu: Flutter SDK và Android SDK; cần Visual Studio với workload C++ phù hợp nếu chạy ứng dụng Windows.

Mở terminal tại thư mục Frontend và chạy:

```powershell
flutter pub get
```

Cấu hình URL Backend theo hướng dẫn trong `.env.example` hoặc README của nhánh Frontend.

Để chạy ứng dụng:

```powershell
flutter run
```

Để chạy trên Windows Desktop:

```powershell
flutter run -d windows
```

Để chạy kiểm thử:

```powershell
flutter test
```

## Hướng dẫn chạy Backend

Yêu cầu: Python, Microsoft SQL Server và ODBC Driver tương thích.

Tạo môi trường ảo:

```powershell
py -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

Tạo file cấu hình môi trường từ file mẫu:

```powershell
Copy-Item .env.example .env
```

Cập nhật các biến cấu hình trong `.env` theo môi trường thực tế. Không commit file `.env` lên GitHub.

Khởi tạo cơ sở dữ liệu và dữ liệu demo theo hướng dẫn của dự án. Chỉ chạy script khởi tạo sau khi đã kiểm tra ảnh hưởng của nó đối với cơ sở dữ liệu.

Khởi động API:

```powershell
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Tài liệu API khi chạy cục bộ:

- Swagger UI: http://127.0.0.1:8000/docs
- ReDoc: http://127.0.0.1:8000/redoc

Các địa chỉ trên chỉ truy cập được từ máy có Backend đang chạy, trừ khi bạn cấu hình triển khai công khai.

## Chức năng chính

- Đăng nhập và xác thực OTP.
- Quản lý phiên đăng nhập bằng JWT.
- Chấm công vào ca và ra ca.
- Xem lịch sử chấm công.
- Quản lý nhân viên, phòng ban và ca làm việc.
- Phân quyền người dùng.
- Kết nối Frontend với Backend thông qua API.

Danh sách chức năng và endpoint cần được đối chiếu với mã nguồn thực tế trước khi nghiệm thu.

## Cấu hình và bảo mật

- `.env.example` chỉ chứa tên biến và giá trị minh họa không nhạy cảm.
- `.env` không được commit lên GitHub.
- Không lưu mật khẩu thật, token hoặc thông tin kết nối cơ sở dữ liệu trong tài liệu công khai.
- Tài khoản demo phải được khởi tạo riêng cho môi trường phát triển và sử dụng mật khẩu demo phù hợp.
- Không sử dụng dữ liệu demo trên hệ thống thật nếu chưa được kiểm tra.

## Tài liệu bổ sung

- `FUNCTIONS.txt`: mô tả chức năng của hệ thống.
- `DEMO_ACCOUNTS.txt`: hướng dẫn tài khoản demo nếu được cung cấp an toàn.
- `requirements.txt`: danh sách thư viện Backend.
- `pubspec.yaml`: cấu hình dependencies của Flutter.

