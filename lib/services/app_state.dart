import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const defaultApi = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.1.33:8000');
  String apiBase = defaultApi, access = '', refresh = '', role = '';
  Map<String, dynamic>? me;
  bool busy = false;
  String? error;

  Future<void> restore() async {
    final p = await SharedPreferences.getInstance();
    apiBase = p.getString('api') ?? defaultApi;
    access = p.getString('access') ?? '';
    refresh = p.getString('refresh') ?? '';
    role = p.getString('role') ?? '';
    if (access.isNotEmpty) {
      try {
        me = Map<String, dynamic>.from(await request('GET', '/auth/me'));
      } catch (_) {
        await logout();
      }
    }
    notifyListeners();
  }

  Future<void> setApi(String value) async {
    apiBase = value.replaceAll(RegExp(r'/$'), '');
    final p = await SharedPreferences.getInstance();
    await p.setString('api', apiBase);
    notifyListeners();
  }

  Uri uri(String path) => Uri.parse('$apiBase$path');
  Future<dynamic> request(String method, String path,
      {Map<String, dynamic>? body, bool auth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      if (auth && access.isNotEmpty) 'Authorization': 'Bearer $access'
    };
    late http.Response r;
    switch (method) {
      case 'GET':
        r = await http
            .get(uri(path), headers: headers)
            .timeout(const Duration(seconds: 20));
        break;
      case 'POST':
        r = await http
            .post(uri(path), headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 20));
        break;
      case 'PUT':
        r = await http
            .put(uri(path), headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 20));
        break;
      case 'PATCH':
        r = await http
            .patch(uri(path), headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 20));
        break;
      case 'DELETE':
        r = await http
            .delete(uri(path), headers: headers)
            .timeout(const Duration(seconds: 20));
        break;
      default:
        throw Exception('Phương thức API không hỗ trợ');
    }
    dynamic data;
    try {
      data = r.body.isEmpty ? null : jsonDecode(utf8.decode(r.bodyBytes));
    } catch (_) {
      data = r.body;
    }
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception(data is Map
          ? (data['detail'] ?? 'Lỗi máy chủ')
          : 'Lỗi HTTP ${r.statusCode}');
    }
    return data;
  }

  Future<T> run<T>(Future<T> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      return await action();
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      rethrow;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) => run(
      () async => Map<String, dynamic>.from(await request('POST', '/auth/login',
          auth: false, body: {'username': username, 'password': password})));
  Future<void> verifyOtp(String token, String otp) => run(() async {
        final d = Map<String, dynamic>.from(await request(
            'POST', '/auth/verify-otp',
            auth: false, body: {'challenge_token': token, 'otp': otp}));
        access = d['access_token'];
        refresh = d['refresh_token'];
        role = d['role'];
        final p = await SharedPreferences.getInstance();
        await p.setString('access', access);
        await p.setString('refresh', refresh);
        await p.setString('role', role);
        me = Map<String, dynamic>.from(await request('GET', '/auth/me'));
      });
  Future<void> register(
          String username, String email, String password, String confirm) =>
      run(() async {
        await request('POST', '/auth/register', auth: false, body: {
          'username': username,
          'email': email,
          'password': password,
          'confirm_password': confirm
        });
      });
  Future<void> verifyEmail(String email, String code) => run(() async {
        await request('POST', '/auth/verify-email',
            auth: false, body: {'email': email, 'code': code});
      });
  Future<void> logout() async {
    access = '';
    refresh = '';
    role = '';
    me = null;
    final p = await SharedPreferences.getInstance();
    await p.remove('access');
    await p.remove('refresh');
    await p.remove('role');
    notifyListeners();
  }

  Future<dynamic> get(String path) => request('GET', path);
  Future<dynamic> save(String path, Map<String, dynamic> data,
          {bool update = false}) =>
      request(update ? 'PUT' : 'POST', path, body: data);
  Future<void> remove(String path) async {
    await request('DELETE', path);
  }

  Future<dynamic> action(String path) => run(() => request('POST', path));

  // ---------- Đăng nhập bằng khuôn mặt ----------
  Future<void> faceRegister(String faceData) => run(() async {
        await request('POST', '/auth/face-register', body: {'face_data': faceData});
      });

  Future<bool> faceStatus() async {
    final d = Map<String, dynamic>.from(await request('GET', '/auth/face-status'));
    return d['has_face'] == true;
  }

  Future<void> faceLogin(String username, String faceData) => run(() async {
        final d = Map<String, dynamic>.from(await request(
            'POST', '/auth/face-login',
            auth: false, body: {'username': username, 'face_data': faceData}));
        access = d['access_token'];
        refresh = d['refresh_token'];
        role = d['role'];
        final p = await SharedPreferences.getInstance();
        await p.setString('access', access);
        await p.setString('refresh', refresh);
        await p.setString('role', role);
        me = Map<String, dynamic>.from(await request('GET', '/auth/me'));
      });
}
