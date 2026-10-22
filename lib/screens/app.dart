import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../services/app_state.dart';
import 'mlkit_translate_screen.dart';

// ==========================================
// BẢNG MÀU & HỆ THỐNG THIẾT KẾ HIỆN ĐẠI
// ==========================================
class AppColors {
  static const primary = Color(0xFF0F3E85); // Xanh Navy sâu, chuyên nghiệp
  static const primaryLight = Color(0xFF1E60D5);
  static const primaryDark = Color(0xFF0A295C);
  static const secondary = Color(0xFF0284C7); // Xanh ngọc điểm nhấn
  static const background = Color(0xFFF8FAFC); // Nền sáng dịu mắt
  static const surface = Colors.white;
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);

  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFECFDF5);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFFFBEB);
  static const error = Color(0xFFEF4444);
  static const errorBg = Color(0xFFFEF2F2);
  static const info = Color(0xFF3B82F6);
  static const infoBg = Color(0xFFEFF6FF);
}

// ==========================================
// WIDGET GỐC ỨNG DỤNG (MATERIAL APP)
// ==========================================
class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chấm Công Nhân Viên',
      debugShowCheckedModeBanner: false,
      // Cấu hình Localization đầy đủ cho Tiếng Việt
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('vi', 'VN'),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          surfaceTint: Colors.transparent,
        ),
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 1),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 1.8),
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.2),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 2,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              );
            }
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: AppColors.textSecondary,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primary, size: 24);
            }
            return const IconThemeData(color: AppColors.textSecondary, size: 24);
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: Consumer<AppState>(
        builder: (context, state, _) =>
            state.access.isEmpty ? const LoginPage() : const HomePage(),
      ),
    );
  }
}

// ==========================================
// HÀM TIỆN ÍCH THÔNG BÁO & FORMAT TIẾNG VIỆT
// ==========================================
void toast(BuildContext context, Object message, {bool isSuccess = false}) {
  final text = message.toString().replaceFirst('Exception: ', '').trim();
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: isSuccess ? AppColors.success : const Color(0xFF334155),
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.info_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}

String formatRoleName(String role) {
  switch (role.toLowerCase()) {
    case 'admin':
      return 'Quản trị viên';
    case 'employee':
      return 'Nhân viên';
    case 'customer':
      return 'Khách hàng';
    default:
      return role.isEmpty ? 'Chưa phân quyền' : role;
  }
}

String formatVietnameseDate(String? rawDate) {
  if (rawDate == null || rawDate.isEmpty) return '—';
  try {
    final parsed = DateTime.parse(rawDate);
    return DateFormat('dd/MM/yyyy', 'vi_VN').format(parsed);
  } catch (_) {
    return rawDate;
  }
}

String formatVietnameseTime(String? rawTime) {
  if (rawTime == null || rawTime.isEmpty) return '—';
  if (rawTime.contains('T')) {
    try {
      final parsed = DateTime.parse(rawTime);
      return DateFormat('HH:mm', 'vi_VN').format(parsed);
    } catch (_) {
      return rawTime;
    }
  }
  // Nếu là HH:mm:ss, lấy HH:mm
  final parts = rawTime.split(':');
  if (parts.length >= 2) {
    return '${parts[0]}:${parts[1]}';
  }
  return rawTime;
}

// ==========================================
// MÀN HÌNH ĐĂNG NHẬP, ĐĂNG KÝ & XÁC THỰC OTP
// ==========================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _apiCtrl = TextEditingController();

  String? _challengeToken;
  bool _isRegister = false;
  bool _isVerifyEmail = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _showApiConfig = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _apiCtrl.dispose();
    super.dispose();
  }

  Future<void> _pasteCode() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _codeCtrl.text = data.text!.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (_apiCtrl.text.isEmpty) {
      _apiCtrl.text = s.apiBase;
    }

    final isOtpScreen = _challengeToken != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Tiêu đề thương hiệu
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        isOtpScreen
                            ? Icons.security_rounded
                            : _isVerifyEmail
                                ? Icons.mark_email_read_rounded
                                : Icons.access_time_filled_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isOtpScreen
                        ? 'Xác thực mã OTP'
                        : _isVerifyEmail
                            ? 'Xác thực địa chỉ Email'
                            : _isRegister
                                ? 'Tạo tài khoản mới'
                                : 'Hệ Thống Chấm Công',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isOtpScreen
                        ? 'Nhập mã xác thực 6 số gửi tới tài khoản của bạn'
                        : _isVerifyEmail
                            ? 'Nhập mã kích hoạt đã gửi tới email của bạn'
                            : _isRegister
                                ? 'Đăng ký tài khoản để bắt đầu chấm công'
                                : 'Đăng nhập để quản lý ca làm việc và chấm công',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Khung thông báo lỗi (nếu có)
                  if (s.error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.errorBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.error!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form nhập liệu
                  if (!isOtpScreen && !_isVerifyEmail) ...[
                    TextField(
                      controller: _userCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Tên đăng nhập',
                        hintText: 'Nhập tên đăng nhập',
                        prefixIcon: Icon(Icons.person_outline_rounded,
                            color: AppColors.primaryLight),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (_isRegister) ...[
                      TextField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ Email',
                          hintText: 'vidu@congty.com',
                          prefixIcon: Icon(Icons.mail_outline_rounded,
                              color: AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscurePassword,
                      textInputAction:
                          _isRegister ? TextInputAction.next : TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu',
                        hintText: 'Nhập mật khẩu',
                        prefixIcon: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.primaryLight),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (_isRegister) ...[
                      TextField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          hintText: 'Nhập lại mật khẩu',
                          prefixIcon: const Icon(Icons.lock_reset_rounded,
                              color: AppColors.primaryLight),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textMuted,
                            ),
                            onPressed: () =>
                                setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Cấu hình máy chủ API (Mở rộng khi cần)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () =>
                            setState(() => _showApiConfig = !_showApiConfig),
                        icon: Icon(
                          _showApiConfig
                              ? Icons.keyboard_arrow_up
                              : Icons.settings_outlined,
                          size: 16,
                        ),
                        label: Text(
                          _showApiConfig
                              ? 'Thu gọn cài đặt'
                              : 'Cài đặt máy chủ API',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    if (_showApiConfig) ...[
                      const SizedBox(height: 4),
                      TextField(
                        controller: _apiCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ máy chủ API',
                          helperText: 'Điện thoại thật: http://192.168.1.33:8000 (Wi-Fi) hoặc http://localhost:8000 (cáp USB)',
                          prefixIcon: Icon(Icons.dns_outlined,
                              color: AppColors.primaryLight),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],

                  // Form OTP & Verify Email
                  if (isOtpScreen || _isVerifyEmail) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _codeCtrl,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                            ),
                            decoration: InputDecoration(
                              labelText: isOtpScreen
                                  ? 'Mã OTP (6 chữ số)'
                                  : 'Mã xác thực email',
                              hintText: '••••••',
                              prefixIcon: const Icon(Icons.verified_user_outlined,
                                  color: AppColors.primaryLight),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: _pasteCode,
                              icon: const Icon(Icons.content_paste_rounded, size: 16),
                              label: const Text('Dán mã từ bộ nhớ tạm'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Nút bấm hành động chính
                  FilledButton(
                    onPressed: s.busy
                        ? null
                        : () async {
                            try {
                              if (_isVerifyEmail) {
                                if (_emailCtrl.text.trim().isEmpty ||
                                    _codeCtrl.text.trim().isEmpty) {
                                  toast(context, 'Vui lòng nhập email và mã xác thực');
                                  return;
                                }
                                if (_apiCtrl.text.trim().isNotEmpty) {
                                  await s.setApi(_apiCtrl.text.trim());
                                }
                                await s.verifyEmail(
                                    _emailCtrl.text.trim(), _codeCtrl.text.trim());
                                if (!context.mounted) return;
                                toast(context, 'Xác thực email thành công! Hãy đăng nhập.',
                                    isSuccess: true);
                                setState(() {
                                  _isVerifyEmail = false;
                                  _isRegister = false;
                                  _codeCtrl.clear();
                                });
                              } else if (isOtpScreen) {
                                if (_codeCtrl.text.trim().isEmpty) {
                                  toast(context, 'Vui lòng nhập mã xác thực OTP');
                                  return;
                                }
                                if (_apiCtrl.text.trim().isNotEmpty) {
                                  await s.setApi(_apiCtrl.text.trim());
                                }
                                await s.verifyOtp(
                                    _challengeToken!, _codeCtrl.text.trim());
                              } else if (_isRegister) {
                                if (_userCtrl.text.trim().isEmpty ||
                                    _emailCtrl.text.trim().isEmpty ||
                                    _passCtrl.text.isEmpty) {
                                  toast(context, 'Vui lòng điền đầy đủ thông tin');
                                  return;
                                }
                                if (_passCtrl.text != _confirmCtrl.text) {
                                  toast(context, 'Mật khẩu xác nhận không khớp');
                                  return;
                                }
                                if (_apiCtrl.text.trim().isNotEmpty) {
                                  await s.setApi(_apiCtrl.text.trim());
                                }
                                await s.register(
                                  _userCtrl.text.trim(),
                                  _emailCtrl.text.trim(),
                                  _passCtrl.text,
                                  _confirmCtrl.text,
                                );
                                if (!context.mounted) return;
                                toast(context, 'Đăng ký thành công! Hãy kiểm tra mã xác thực.',
                                    isSuccess: true);
                                setState(() {
                                  _isVerifyEmail = true;
                                });
                              } else {
                                if (_userCtrl.text.trim().isEmpty ||
                                    _passCtrl.text.isEmpty) {
                                  toast(context, 'Vui lòng nhập tên đăng nhập và mật khẩu');
                                  return;
                                }
                                if (_apiCtrl.text.trim().isNotEmpty) {
                                  await s.setApi(_apiCtrl.text.trim());
                                }
                                final data = await s.login(
                                  _userCtrl.text.trim(),
                                  _passCtrl.text,
                                );
                                if (!context.mounted) return;
                                setState(() {
                                  _challengeToken = data['challenge_token'];
                                });
                              }
                            } catch (e) {
                              if (context.mounted) {
                                toast(context, e);
                              }
                            }
                          },
                    child: s.busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isOtpScreen
                                ? 'Xác nhận OTP'
                                : _isVerifyEmail
                                    ? 'Xác thực tài khoản'
                                    : _isRegister
                                        ? 'Đăng ký tài khoản'
                                        : 'Đăng nhập',
                          ),
                  ),

                  // Nút chuyển đổi chế độ / Quay lại
                  const SizedBox(height: 12),
                  if (isOtpScreen || _isVerifyEmail)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _challengeToken = null;
                          _isVerifyEmail = false;
                          _codeCtrl.clear();
                        });
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Quay lại màn hình đăng nhập'),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegister = !_isRegister;
                          _isVerifyEmail = false;
                          _challengeToken = null;
                          _codeCtrl.clear();
                        });
                      },
                      child: Text(
                        _isRegister
                            ? 'Đã có tài khoản? Đăng nhập ngay'
                            : 'Chưa có tài khoản? Đăng ký ngay',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                  // Nút đăng nhập bằng khuôn mặt
                  if (!_isRegister && !isOtpScreen && !_isVerifyEmail) ...[
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'hoặc',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: AppColors.primaryLight,
                          width: 1.5,
                        ),
                      ),
                      onPressed: s.busy
                          ? null
                          : () async {
                              final username = _userCtrl.text.trim();
                              if (username.isEmpty) {
                                toast(context,
                                    'Vui lòng nhập tên đăng nhập trước');
                                return;
                              }

                              // Xác thực sinh trắc học thiết bị
                              try {
                                final localAuth = LocalAuthentication();
                                final canCheck =
                                    await localAuth.canCheckBiometrics;
                                final isSupported =
                                    await localAuth.isDeviceSupported();
                                if (canCheck || isSupported) {
                                  final bioOk = await localAuth.authenticate(
                                    localizedReason:
                                        'Xác thực sinh trắc học để đăng nhập',
                                    options: const AuthenticationOptions(
                                      stickyAuth: true,
                                      biometricOnly: false,
                                    ),
                                  );
                                  if (!bioOk) {
                                    if (context.mounted) {
                                      toast(context,
                                          'Xác thực sinh trắc học thất bại');
                                    }
                                    return;
                                  }
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  toast(context,
                                      'Lỗi sinh trắc học: $e');
                                }
                                return;
                              }

                              // Chụp ảnh khuôn mặt
                              try {
                                final f = await ImagePicker().pickImage(
                                  source: ImageSource.camera,
                                  preferredCameraDevice: CameraDevice.front,
                                  maxWidth: 640,
                                  maxHeight: 640,
                                  imageQuality: 80,
                                );
                                if (f == null) return;
                                final bytes = await f.readAsBytes();
                                final faceData = base64Encode(bytes);

                                // Đăng nhập bằng khuôn mặt
                                await s.setApi(_apiCtrl.text.trim());
                                await s.faceLogin(username, faceData);
                              } catch (e) {
                                if (context.mounted) {
                                  toast(context, e);
                                }
                              }
                            },
                      icon: const Icon(
                        Icons.face_retouching_natural_rounded,
                        color: AppColors.primaryLight,
                      ),
                      label: const Text(
                        'Đăng nhập bằng Khuôn Mặt',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH CHÍNH (NAVIGATION BAR)
// ==========================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final isAdmin = s.role == 'admin';
    final isCustomer = s.role == 'customer';

    final pages = isAdmin
        ? [const AdminPage(), const DemoHub(), const ProfilePage()]
        : isCustomer
            ? [const HistoryPage(), const DemoHub(), const ProfilePage()]
            : [
                const EmployeePage(),
                const HistoryPage(),
                const DemoHub(),
                const ProfilePage()
              ];

    final labels = isAdmin
        ? ['Quản trị', 'Tiện ích', 'Tài khoản']
        : isCustomer
            ? ['Lịch sử', 'Tiện ích', 'Tài khoản']
            : ['Chấm công', 'Lịch sử', 'Tiện ích', 'Tài khoản'];

    final icons = isAdmin
        ? [Icons.dashboard_outlined, Icons.auto_awesome_outlined, Icons.person_outline]
        : isCustomer
            ? [Icons.history_rounded, Icons.auto_awesome_outlined, Icons.person_outline]
            : [
                Icons.access_time_rounded,
                Icons.history_rounded,
                Icons.auto_awesome_outlined,
                Icons.person_outline
              ];

    final selectedIcons = isAdmin
        ? [Icons.dashboard_rounded, Icons.auto_awesome, Icons.person]
        : isCustomer
            ? [Icons.history_rounded, Icons.auto_awesome, Icons.person]
            : [
                Icons.access_time_filled_rounded,
                Icons.history_rounded,
                Icons.auto_awesome,
                Icons.person
              ];

    if (_currentTab >= pages.length) {
      _currentTab = 0;
    }

    return Scaffold(
      body: SafeArea(child: pages[_currentTab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentTab,
        onDestinationSelected: (idx) => setState(() => _currentTab = idx),
        destinations: List.generate(
          labels.length,
          (i) => NavigationDestination(
            icon: Icon(icons[i]),
            selectedIcon: Icon(selectedIcons[i]),
            label: labels[i],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// KHUNG TRANG CHUNG (PAGE FRAME TIÊU CHUẨN)
// ==========================================
class PageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const PageFrame(this.title, {required this.child, this.actions, super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Text(title),
          floating: true,
          pinned: false,
          actions: actions,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          sliver: SliverToBoxAdapter(child: child),
        ),
      ],
    );
  }
}

// ==========================================
// MÀN HÌNH CHẤM CÔNG NHÂN VIÊN
// ==========================================
class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  Map<String, dynamic>? _record;
  bool _loading = true;
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadRecord();
    // Cập nhật đồng hồ thời gian thực mỗi giây
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  Future<void> _loadRecord() async {
    try {
      final list = await context.read<AppState>().get('/attendance/me');
      if (mounted) {
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        Map<String, dynamic>? todayRecord;
        if (list is List && list.isNotEmpty) {
          for (final item in list) {
            final m = Map<String, dynamic>.from(item);
            if (m['work_date']?.toString().startsWith(todayStr) == true) {
              todayRecord = m;
              break;
            }
          }
        }
        setState(() {
          _record = todayRecord;
        });
      }
    } catch (e) {
      if (mounted) {
        toast(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final username = s.me?['username'] ?? 'Nhân viên';

    final hasCheckedIn = _record != null;
    final hasCheckedOut = _record?['check_out'] != null;

    final checkInTime = formatVietnameseTime(_record?['check_in']);
    final checkOutTime = formatVietnameseTime(_record?['check_out']);

    return PageFrame(
      'Xin chào, $username',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thẻ Hero Card chấm công hôm nay
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'HÔM NAY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('HH:mm:ss', 'vi_VN').format(_currentTime),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_currentTime),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),

                // Thông tin Giờ vào - Giờ ra
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Giờ vào',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hasCheckedIn ? checkInTime : '—:—',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 36, color: Colors.white24),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Giờ ra',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasCheckedOut ? checkOutTime : '—:—',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Trạng thái và Nút hành động Chấm công
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (!hasCheckedIn)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: s.busy
                  ? null
                  : () async {
                      try {
                        await s.action('/attendance/check-in');
                        if (!context.mounted) return;
                        toast(context, 'Chấm công vào ca thành công!', isSuccess: true);
                        await _loadRecord();
                      } catch (e) {
                        if (context.mounted) toast(context, e);
                      }
                    },
              icon: s.busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.login_rounded, size: 22),
              label: const Text(
                'CHẤM CÔNG VÀO CA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          else if (!hasCheckedOut)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: s.busy
                  ? null
                  : () async {
                      try {
                        await s.action('/attendance/check-out');
                        if (!context.mounted) return;
                        toast(context, 'Chấm công ra ca thành công!', isSuccess: true);
                        await _loadRecord();
                      } catch (e) {
                        if (context.mounted) toast(context, e);
                      }
                    },
              icon: s.busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.logout_rounded, size: 22),
              label: const Text(
                'CHẤM CÔNG RA CA',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.successBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đã hoàn thành ca làm việc',
                          style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Bạn đã hoàn thành đủ lượt chấm công vào và ra hôm nay.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Cảnh báo đi muộn (nếu có)
          if (_record?['is_late'] == true) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.access_time_rounded, color: AppColors.warning, size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hôm nay bạn đi muộn so với quy định ca làm việc.',
                      style: TextStyle(
                        color: Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Cảnh báo nghi ngờ & Buddy QR
          if (_record?['is_suspicious'] == true) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFFED7AA), width: 1.2),
              ),
              color: const Color(0xFFFFF7ED),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.people_alt_rounded,
                          color: Colors.deepOrange, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Yêu cầu xác nhận đồng nghiệp',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF9A3412),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Nhờ đồng nghiệp quét mã QR của bạn để xác minh có mặt.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.qr_code_rounded, size: 16),
                            label: const Text('Mở mã QR của tôi',
                                style: TextStyle(fontSize: 12.5)),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const BuddyQrPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Card thông tin ca làm việc tiêu chuẩn
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ca làm việc tiêu chuẩn',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Thời gian: 08:00 – 17:00 • Thứ 2 đến Thứ 6',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH LỊCH SỬ CHẤM CÔNG
// ==========================================
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<dynamic> _historyFuture;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    setState(() {
      _historyFuture = context.read<AppState>().get('/attendance/me');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Chấm Công'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: _fetchHistory,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchHistory(),
        child: FutureBuilder(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppColors.error, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Không thể tải dữ liệu lịch sử',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _fetchHistory,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final rows = (snapshot.data as List).cast<Map>();

            if (rows.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(36.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event_busy_rounded,
                            color: AppColors.primary, size: 48),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Chưa có dữ liệu chấm công',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Các bản ghi chấm công của bạn sẽ xuất hiện tại đây sau khi điểm danh.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final r = rows[index];
                final isLate = r['is_late'] == true;
                final isSuspicious = r['is_suspicious'] == true;
                final checkIn = formatVietnameseTime(r['check_in']);
                final checkOut = formatVietnameseTime(r['check_out']);
                final workDate = formatVietnameseDate(r['work_date']?.toString());

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    size: 16, color: AppColors.primaryLight),
                                const SizedBox(width: 8),
                                Text(
                                  workDate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            // Badge trạng thái
                            if (isSuspicious)
                              _statusBadge('Cần xác minh', AppColors.error, AppColors.errorBg)
                            else if (isLate)
                              _statusBadge('Đi muộn', AppColors.warning, AppColors.warningBg)
                            else
                              _statusBadge('Đúng giờ', AppColors.success, AppColors.successBg),
                          ],
                        ),
                        const Divider(height: 20, color: AppColors.border),
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.login_rounded,
                                      size: 18, color: AppColors.success),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Vào ca',
                                          style: TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.textSecondary)),
                                      Text(
                                        checkIn,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Icon(Icons.logout_rounded,
                                      size: 18, color: AppColors.warning),
                                  const SizedBox(width: 6),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Ra ca',
                                          style: TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.textSecondary)),
                                      Text(
                                        checkOut == '—' ? 'Chưa ra ca' : checkOut,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: checkOut == '—'
                                              ? AppColors.textMuted
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH QUẢN TRỊ VIÊN (ADMIN DASHBOARD)
// ==========================================
class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {
        'title': 'Quản lý nhân viên',
        'subtitle': 'Hồ sơ nhân viên, liên hệ, phòng ban',
        'path': 'employees',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF0284C7),
      },
      {
        'title': 'Quản lý phòng ban',
        'subtitle': 'Cơ cấu phòng ban và tổ chức công ty',
        'path': 'departments',
        'icon': Icons.business_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'title': 'Quản lý ca làm việc',
        'subtitle': 'Thời gian bắt đầu, kết thúc ca',
        'path': 'shifts',
        'icon': Icons.schedule_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'title': 'Lịch sử chấm công hệ thống',
        'subtitle': 'Toàn bộ dữ liệu điểm danh của nhân viên',
        'path': '/attendance/records',
        'icon': Icons.fact_check_rounded,
        'color': const Color(0xFFEA580C),
      },
      {
        'title': 'Tài khoản & Phân quyền',
        'subtitle': 'Phân quyền Admin, Nhân viên, Khách hàng',
        'path': '/admin/users',
        'icon': Icons.admin_panel_settings_rounded,
        'color': const Color(0xFF059669),
      },
    ];

    return PageFrame(
      'Trung Tâm Quản Trị',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hệ thống quản trị chấm công',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Chọn một danh mục bên dưới để xem, cập nhật hoặc thêm mới dữ liệu.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...modules.map((m) {
            final color = m['color'] as Color;
            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(m['icon'] as IconData, color: color, size: 24),
                ),
                title: Text(
                  m['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                subtitle: Text(
                  m['subtitle'] as String,
                  style: const TextStyle(fontSize: 12.5),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: AppColors.textMuted),
                onTap: () {
                  final path = m['path'] as String;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => path == '/admin/users'
                          ? const UsersPage()
                          : CrudPage(m['title'] as String, path),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH QUẢN LÝ TÀI KHOẢN & PHÂN QUYỀN
// ==========================================
class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  late Future<dynamic> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = context.read<AppState>().get('/admin/users');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài Khoản & Phân Quyền'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: FutureBuilder(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Lỗi tải danh sách người dùng: ${snapshot.error}'),
              ),
            );
          }

          final rows = (snapshot.data as List).cast<Map>();
          if (rows.isEmpty) {
            return const Center(child: Text('Chưa có tài khoản nào'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final u = rows[index];
              final isVerified = u['is_verified'] == true;
              final currentRole = '${u['role']}';

              return Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        foregroundColor: AppColors.primary,
                        child: Text(
                          (u['username'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${u['username']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            Text(
                              '${u['email'] ?? 'Chưa có email'}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? AppColors.successBg
                                    : AppColors.errorBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isVerified ? 'Đã xác minh' : 'Chưa xác minh',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isVerified
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Dropdown phân quyền tiếng Việt
                      DropdownButtonHideUnderline(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButton<String>(
                            value: currentRole,
                            items: const [
                              DropdownMenuItem(
                                value: 'admin',
                                child: Text('Quản trị viên'),
                              ),
                              DropdownMenuItem(
                                value: 'employee',
                                child: Text('Nhân viên'),
                              ),
                              DropdownMenuItem(
                                value: 'customer',
                                child: Text('Khách hàng'),
                              ),
                            ],
                            onChanged: (role) async {
                              if (role == null || role == currentRole) return;
                              try {
                                await context.read<AppState>().request(
                                  'PATCH',
                                  '/admin/users/${u['id']}/role',
                                  body: {'role': role},
                                );
                                if (context.mounted) {
                                  toast(context, 'Đã cập nhật quyền thành công!',
                                      isSuccess: true);
                                }
                                _loadUsers();
                              } catch (e) {
                                if (context.mounted) toast(context, e);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH CRUD DỮ LIỆU TỔNG QUÁT (TIẾNG VIỆT)
// ==========================================
class CrudPage extends StatefulWidget {
  final String title;
  final String path;

  const CrudPage(this.title, this.path, {super.key});

  @override
  State<CrudPage> createState() => _CrudPageState();
}

class _CrudPageState extends State<CrudPage> {
  late Future<dynamic> _dataFuture;
  final Map<String, TextEditingController> _ctrls = {};

  String get _endpoint =>
      widget.path.startsWith('/') ? widget.path : '/admin/${widget.path}';

  List<String> get _fields {
    if (widget.path == 'employees') {
      return ['full_name', 'email', 'phone', 'department_id', 'user_id'];
    }
    if (widget.path == 'departments') {
      return ['name'];
    }
    if (widget.path == 'shifts') {
      return ['name', 'start_time', 'end_time', 'is_active'];
    }
    return ['employee_id', 'check_in', 'check_out'];
  }

  String _fieldLabel(String field) {
    switch (field) {
      case 'full_name':
        return 'Họ và tên';
      case 'email':
        return 'Địa chỉ Email';
      case 'phone':
        return 'Số điện thoại';
      case 'department_id':
        return 'Mã phòng ban (ID)';
      case 'user_id':
        return 'Mã tài khoản (ID)';
      case 'name':
        return 'Tên gọi';
      case 'start_time':
        return 'Giờ bắt đầu';
      case 'end_time':
        return 'Giờ kết thúc';
      case 'is_active':
        return 'Đang hoạt động';
      case 'employee_id':
        return 'Mã nhân viên (ID)';
      case 'check_in':
        return 'Giờ vào ca';
      case 'check_out':
        return 'Giờ ra ca';
      default:
        return field;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _dataFuture = context.read<AppState>().get(_endpoint);
    });
  }

  Future<void> _openEditDialog([Map? row]) async {
    _ctrls.clear();
    bool isActiveValue = true;

    for (final f in _fields) {
      if (f == 'is_active') {
        isActiveValue = row?['is_active'] ?? true;
      } else {
        _ctrls[f] = TextEditingController(text: row?[f]?.toString() ?? '');
      }
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                '${row == null ? 'Thêm mới' : 'Chỉnh sửa'} ${widget.title.toLowerCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ..._fields.map((field) {
                      if (field == 'is_active') {
                        return SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Đang kích hoạt'),
                          value: isActiveValue,
                          onChanged: (val) {
                            setDialogState(() => isActiveValue = val);
                          },
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: TextField(
                          controller: _ctrls[field],
                          decoration: InputDecoration(
                            labelText: _fieldLabel(field),
                            helperText: (field == 'start_time' || field == 'end_time')
                                ? 'Định dạng giờ: HH:MM:SS (ví dụ 08:00:00)'
                                : null,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () async {
                    try {
                      final body = <String, dynamic>{};
                      for (final f in _fields) {
                        if (f == 'is_active') {
                          body['is_active'] = isActiveValue;
                          continue;
                        }
                        final text = _ctrls[f]!.text.trim();
                        if (text.isEmpty) {
                          body[f] = null;
                        } else if (['department_id', 'user_id', 'employee_id']
                            .contains(f)) {
                          body[f] = int.tryParse(text);
                        } else {
                          body[f] = text;
                        }
                      }

                      await context.read<AppState>().save(
                            '$_endpoint${row == null ? '' : '/${row['id']}'}',
                            body,
                            update: row != null,
                          );

                      if (!mounted || !dialogContext.mounted) return;
                      Navigator.pop(dialogContext);
                      toast(
                        context,
                        '${row == null ? 'Thêm mới' : 'Cập nhật'} thành công!',
                        isSuccess: true,
                      );
                      _loadData();
                    } catch (e) {
                      if (dialogContext.mounted) toast(dialogContext, e);
                    }
                  },
                  child: const Text('Lưu thông tin'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(dynamic id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa dữ liệu này không? Thao tác này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        await context.read<AppState>().remove('$_endpoint/$id');
        if (!mounted) return;
        toast(context, 'Đã xóa bản ghi thành công!', isSuccess: true);
        _loadData();
      } catch (e) {
        if (mounted) toast(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Tải lại',
            onPressed: _loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openEditDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm mới', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Lỗi: ${snapshot.error}'),
              ),
            );
          }

          final rows = (snapshot.data as List).cast<Map>();
          if (rows.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.folder_open_rounded,
                        size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text(
                      'Chưa có dữ liệu nào',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Bấm nút "Thêm mới" bên dưới để tạo bản ghi đầu tiên.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final r = rows[index];
              final titleText =
                  r['full_name'] ?? r['name'] ?? 'Bản ghi #${r['id']}';

              return Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    '$titleText',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      r.entries
                          .where((e) =>
                              e.key != 'password_hash' &&
                              e.key != 'id' &&
                              e.key != 'full_name' &&
                              e.key != 'name')
                          .map((e) => '${_fieldLabel(e.key)}: ${e.value ?? '—'}')
                          .join('\n'),
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary),
                        tooltip: 'Chỉnh sửa',
                        onPressed: () => _openEditDialog(r),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppColors.error),
                        tooltip: 'Xóa',
                        onPressed: () => _confirmDelete(r['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH TIỆN ÍCH NÂNG CAO (DEMO HUB)
// ==========================================
class DemoHub extends StatelessWidget {
  const DemoHub({super.key});

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      'Tiện Ích Nâng Cao',
      child: Column(
        children: [
          _buildFeatureCard(
            context,
            Icons.face_retouching_natural_rounded,
            'Đăng nhập bằng khuôn mặt',
            'Nhận diện khuôn mặt từ camera thời gian thực',
            const FaceDemoPage(),
            Colors.indigo,
          ),
          _buildFeatureCard(
            context,
            Icons.fingerprint_rounded,
            'Sinh trắc học & Quét mã QR',
            'Xác thực vân tay, quét mã xác nhận Buddy Check',
            const VerifyDemoPage(),
            Colors.teal,
          ),
          _buildFeatureCard(
            context,
            Icons.translate_rounded,
            'Google MLKit Dịch Thuật & OCR',
            'Nhận dạng văn bản từ ảnh & dịch ngôn ngữ Offline',
            const MlKitTranslateScreen(),
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget targetPage,
    Color accentColor,
  ) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: accentColor, size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: AppColors.textMuted),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => targetPage),
        ),
      ),
    );
  }
}

// ==========================================
// ĐĂNG KÝ & ĐĂNG NHẬP BẰNG KHUÔN MẶT
// ==========================================
class FaceDemoPage extends StatefulWidget {
  const FaceDemoPage({super.key});

  @override
  State<FaceDemoPage> createState() => _FaceDemoPageState();
}

class _FaceDemoPageState extends State<FaceDemoPage>
    with SingleTickerProviderStateMixin {
  final _localAuth = LocalAuthentication();
  String _status = 'Sẵn sàng xác thực khuôn mặt.';
  bool _isSuccess = false;
  bool _isProcessing = false;
  bool _hasFace = false;
  bool _checkingStatus = true;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _checkFaceStatus();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkFaceStatus() async {
    try {
      final has = await context.read<AppState>().faceStatus();
      if (mounted) {
        setState(() {
          _hasFace = has;
          _checkingStatus = false;
          _status = has
              ? 'Khuôn mặt đã được đăng ký. Bạn có thể cập nhật lại.'
              : 'Chưa đăng ký khuôn mặt. Hãy chụp ảnh để đăng ký.';
        });
      }
    } catch (_) {
      if (mounted) setState(() => _checkingStatus = false);
    }
  }

  Future<String?> _captureAndEncode() async {
    try {
      final f = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 80,
      );
      if (f == null) return null;
      final bytes = await f.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = 'Không thể mở máy ảnh: $e';
          _isSuccess = false;
        });
      }
      return null;
    }
  }

  Future<bool> _biometricCheck() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck && !isSupported) {
        if (mounted) {
          setState(() =>
              _status = 'Thiết bị không hỗ trợ sinh trắc học. Bỏ qua bước này.');
        }
        return true; // Cho phép tiếp tục nếu thiết bị không hỗ trợ
      }
      return await _localAuth.authenticate(
        localizedReason:
            'Xác thực sinh trắc học trước khi chụp ảnh khuôn mặt',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _status = 'Lỗi sinh trắc học: $e');
      }
      return false;
    }
  }

  Future<void> _registerFace() async {
    final appState = context.read<AppState>();
    setState(() {
      _isProcessing = true;
      _status = 'Đang xác thực sinh trắc học thiết bị...';
      _isSuccess = false;
    });

    // Bước 1: Xác thực sinh trắc học thiết bị (vân tay/mặt)
    final bioOk = await _biometricCheck();
    if (!bioOk) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = 'Xác thực sinh trắc học thất bại. Vui lòng thử lại.';
        });
      }
      return;
    }

    if (mounted) setState(() => _status = 'Đang mở camera trước...');

    // Bước 2: Chụp ảnh khuôn mặt
    final faceData = await _captureAndEncode();
    if (faceData == null) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _status = 'Đã hủy chụp ảnh. Vui lòng thử lại.';
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _status = 'Đang gửi dữ liệu khuôn mặt lên máy chủ...');
    }

    // Bước 3: Gửi lên API đăng ký
    try {
      await appState.faceRegister(faceData);
      if (mounted) {
        setState(() {
          _isSuccess = true;
          _hasFace = true;
          _status =
              'Đăng ký khuôn mặt thành công! Bạn có thể đăng nhập bằng khuôn mặt.';
        });
        toast(context, 'Đăng ký khuôn mặt thành công!', isSuccess: true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSuccess = false;
          _status = 'Lỗi đăng ký khuôn mặt: $e';
        });
        toast(context, e);
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác Thực Khuôn Mặt')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),

            // Icon khuôn mặt với hiệu ứng nhịp đập
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isSuccess
                        ? [AppColors.success.withValues(alpha: 0.15),
                           AppColors.success.withValues(alpha: 0.05)]
                        : [AppColors.primary.withValues(alpha: 0.12),
                           AppColors.primaryLight.withValues(alpha: 0.06)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isSuccess ? AppColors.success : AppColors.primary)
                          .withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  _isSuccess
                      ? Icons.check_circle_rounded
                      : Icons.face_retouching_natural_rounded,
                  size: 80,
                  color: _isSuccess ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Đăng Ký Khuôn Mặt',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sử dụng sinh trắc học thiết bị + camera để đăng ký/cập nhật khuôn mặt cho tài khoản.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
            ),
            const SizedBox(height: 20),

            // Trạng thái đăng ký khuôn mặt
            if (_checkingStatus)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else ...[
              // Badge trạng thái
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _hasFace ? AppColors.successBg : AppColors.warningBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (_hasFace ? AppColors.success : AppColors.warning)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasFace
                          ? Icons.verified_rounded
                          : Icons.warning_amber_rounded,
                      color: _hasFace ? AppColors.success : AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _hasFace
                            ? 'Khuôn mặt đã đăng ký ✓'
                            : 'Chưa đăng ký khuôn mặt',
                        style: TextStyle(
                          color:
                              _hasFace ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Thông báo trạng thái chi tiết
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? AppColors.successBg
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSuccess
                        ? AppColors.success.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isSuccess
                        ? AppColors.success
                        : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Nút đăng ký/cập nhật khuôn mặt
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _registerFace,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _hasFace
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(_hasFace
                          ? Icons.refresh_rounded
                          : Icons.camera_alt_rounded),
                  label: Text(
                    _isProcessing
                        ? 'Đang xử lý...'
                        : _hasFace
                            ? 'Cập Nhật Khuôn Mặt'
                            : 'Chụp Ảnh & Đăng Ký Khuôn Mặt',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],

            const Spacer(),

            // Lưu ý cuối trang
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.infoBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.info, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Quy trình: Xác thực sinh trắc học → Chụp ảnh camera trước → Gửi lên máy chủ lưu trữ.',
                      style: TextStyle(color: AppColors.info, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// DEMO SINH TRẮC HỌC & QR
// ==========================================
class VerifyDemoPage extends StatelessWidget {
  const VerifyDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác Thực Thiết Bị')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.fingerprint_rounded,
                  color: AppColors.primary, size: 30),
              title: const Text('Xác thực vân tay',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Sử dụng cảm biến vân tay trên thiết bị Android'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () async {
                try {
                  final ok = await LocalAuthentication().authenticate(
                    localizedReason: 'Vui lòng quét vân tay để xác thực chấm công',
                  );
                  if (context.mounted) {
                    toast(
                      context,
                      ok ? 'Xác thực vân tay thành công!' : 'Xác thực không thành công',
                      isSuccess: ok,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    toast(context, 'Thiết bị chưa hỗ trợ vân tay hoặc chưa cài đặt: $e');
                  }
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.qr_code_scanner_rounded,
                  color: AppColors.primary, size: 30),
              title: const Text('Quét mã đồng nghiệp (Buddy Check)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Quét mã QR để xác nhận điểm danh cho đồng nghiệp'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BuddyScanPage()),
                );
              },
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.nfc_rounded, color: AppColors.primary, size: 30),
              title: Text('Xác thực thẻ NFC',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Mô phỏng giao tiếp thẻ từ nhân viên chạm qua NFC'),
              trailing: Icon(Icons.chevron_right_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH HIỂN THỊ QR BUDDY
// ==========================================
class BuddyQrPage extends StatefulWidget {
  const BuddyQrPage({super.key});

  @override
  State<BuddyQrPage> createState() => _BuddyQrPageState();
}

class _BuddyQrPageState extends State<BuddyQrPage> {
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    context.read<AppState>().get('/attendance/me').then((val) {
      if ((val as List).isNotEmpty && mounted) {
        setState(() {
          _employeeId = '${val.first['employee_id']}';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mã QR Xác Nhận Buddy')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Đưa mã này cho đồng nghiệp quét',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Để xác nhận hai người cùng có mặt tại vị trí làm việc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
              const SizedBox(height: 24),
              if (_employeeId == null)
                const CircularProgressIndicator()
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: 'EMPLOYEE:$_employeeId',
                    size: 220,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                'Mã nhân viên: ${_employeeId ?? '—'}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH QUÉT MÃ QR BUDDY
// ==========================================
class BuddyScanPage extends StatefulWidget {
  const BuddyScanPage({super.key});

  @override
  State<BuddyScanPage> createState() => _BuddyScanPageState();
}

class _BuddyScanPageState extends State<BuddyScanPage> {
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét Mã Đồng Nghiệp')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_sent) return;
          final raw = capture.barcodes.firstOrNull?.rawValue ?? '';
          final match = RegExp(r'EMPLOYEE:(\d+)').firstMatch(raw);
          final id = match?.group(1);
          if (id == null) return;

          _sent = true;
          try {
            await context.read<AppState>().request(
              'POST',
              '/attendance/buddy-confirm',
              body: {'employee_id': int.parse(id), 'method': 'qr'},
            );
            if (context.mounted) {
              toast(context, 'Đã xác nhận chấm công cho đồng nghiệp thành công!',
                  isSuccess: true);
              Navigator.pop(context);
            }
          } catch (e) {
            if (context.mounted) toast(context, e);
            _sent = false;
          }
        },
      ),
    );
  }
}

// ==========================================
// MÀN HÌNH THÔNG TIN TÀI KHOẢN (PROFILE)
// ==========================================
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final username = s.me?['username']?.toString() ?? 'Người dùng';
    final email = s.me?['email']?.toString() ?? 'Chưa cập nhật email';
    final roleName = formatRoleName(s.role);

    return PageFrame(
      'Tài Khoản Cá Nhân',
      child: Column(
        children: [
          // Thẻ hồ sơ người dùng
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Vai trò: $roleName',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Thông tin kết nối hệ thống
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dns_rounded, color: AppColors.primary),
                    title: const Text('Máy chủ API'),
                    subtitle: Text(s.apiBase),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  const ListTile(
                    leading: Icon(Icons.verified_outlined, color: AppColors.primary),
                    title: Text('Phiên bản ứng dụng'),
                    subtitle: Text('v1.0.0 (Bản chuẩn giao diện mới)'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Nút đăng xuất với xác nhận
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.errorBg,
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Text('Xác nhận đăng xuất'),
                  content: const Text(
                      'Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Hủy'),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );

              if (ok == true) {
                await s.logout();
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Đăng xuất tài khoản',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
