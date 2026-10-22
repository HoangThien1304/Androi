# Ứng Dụng Chấm Công Nhân Viên — Frontend (Flutter)

Dự án ứng dụng di động Flutter (hỗ trợ nền tảng Android và Windows Desktop) dành cho hệ thống **Chấm công nhân viên**, kết nối trực tiếp với Web API backend.

---

## 📌 Công Nghệ Sử Dụng
- **Framework**: Flutter 3.x (Dart SDK ^3.5.0)
- **Quản lý State**: `Provider`
- **Networking**: `http`
- **Lưu trữ cục bộ**: `shared_preferences`
- **Xác thực sinh trắc học**: `local_auth`
- **Quét mã & Nhận diện**: `mobile_scanner`, `google_mlkit_text_recognition`, `google_mlkit_face_detection`, `google_mlkit_translation`
- **Nền tảng hỗ trợ**: Android (tối thiểu API 21), Windows Desktop

---

## 📁 Cấu Trúc Thư Mục Nhánh `frontend`
```text
├── android/                 # Mã nguồn và cấu hình native Android
├── lib/                     # Mã nguồn chính Flutter
│   ├── main.dart            # Điểm khởi chạy ứng dụng (main entry point)
│   ├── screens/             # Giao diện màn hình (Login, OTP, Check-in, Admin, Scan, Translate...)
│   └── services/            # Xử lý logic và API client (AppState Provider)
├── test/                    # Kiểm thử đơn vị (widget test)
├── windows/                 # Mã nguồn runner Windows desktop
├── .env.example             # File cấu hình URL API mẫu
├── .gitignore               # Loại trừ file rác, cache và file bí mật
├── analysis_options.yaml    # Cấu hình linter Dart
├── pubspec.yaml             # Khai báo thư viện phụ thuộc
└── pubspec.lock             # Khóa phiên bản dependencies
```

---

## 🛠️ Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

### 1. Yêu Cầu Môi Trường
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Khuyến nghị version >= 3.24.0)
- Android Studio / Android SDK (đã cài Android Virtual Device - AVD hoặc bật chế độ USB Debugging trên điện thoại)
- Visual Studio (nếu muốn build & chạy nền tảng Windows Desktop)

### 2. Cài Đặt Gói Phụ Thuộc
Tại thư mục gốc của dự án, mở terminal và chạy:
```powershell
flutter pub get
```

### 3. Cấu Hình Địa Chỉ API
Tạo file `.env` từ file mẫu:
```powershell
Copy-Item .env.example .env
```
Nội dung file `.env`:
- **Android Emulator**: Sử dụng địa chỉ loopback của máy chủ giả lập:
  ```env
  BASE_URL=http://10.0.2.2:8000
  ```
- **Thiết bị thật (Android qua Wi-Fi)**: Sử dụng IP mạng LAN của máy tính chạy backend:
  ```env
  BASE_URL=http://192.168.1.xxx:8000
  ```

### 4. Khởi Chạy Ứng Dụng
- **Chạy trên thiết bị mặc định (hoặc Emulator đang mở)**:
  ```powershell
  flutter run
  ```
- **Chỉ định chạy với biến môi trường API**:
  ```powershell
  flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  ```
- **Chạy trên Windows Desktop**:
  ```powershell
  flutter run -d windows
  ```

### 5. Kiểm Thử (Unit Test)
```powershell
flutter test
```