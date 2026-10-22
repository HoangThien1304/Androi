-- Migration: Thêm cột face_encoding vào bảng users
-- Chạy trực tiếp trên SQL Server Management Studio hoặc sqlcmd
-- Dùng cho tính năng đăng nhập bằng khuôn mặt

IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'users' AND COLUMN_NAME = 'face_encoding'
)
BEGIN
    ALTER TABLE users ADD face_encoding NVARCHAR(MAX) NULL;
    PRINT N'Đã thêm cột face_encoding vào bảng users.';
END
ELSE
BEGIN
    PRINT N'Cột face_encoding đã tồn tại.';
END
