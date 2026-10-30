// All talking to the Django backend happens in this one file.
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Where the backend lives. 10.0.2.2 is how the Android emulator
/// reaches your computer. For a real phone, put your PC's IP here
/// (example: http://192.168.1.5:8000/api). After deploying, use your live URL.
String get baseUrl {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000/api';
  }
  return 'http://127.0.0.1:8000/api';
}

/// Remembers who is logged in, even after the app is closed.
class Session {
  static String? token;
  static String role = '';
  static String name = '';

  static bool get isLoggedIn => token != null;
  static bool get isAdmin => role == 'admin';

  static Future<void> save(Map<String, dynamic> data) async {
    token = data['token'];
    role = data['role'];
    name = data['name'];
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token!);
    await prefs.setString('role', role);
    await prefs.setString('name', name);
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    role = prefs.getString('role') ?? '';
    name = prefs.getString('name') ?? '';
  }

  static Future<void> clear() async {
    token = null;
    role = '';
    name = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

class Api {
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (Session.token != null) 'Authorization': 'Token ${Session.token}',
      };

  static Future<void> login(String username, String password) async {
    final r = await http.post(Uri.parse('$baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}));
    _check(r);
    await Session.save(jsonDecode(r.body));
  }

  static Future<void> register(
      String username, String password, String name, String studentId) async {
    final r = await http.post(Uri.parse('$baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'first_name': name,
          'student_id': studentId,
        }));
    _check(r);
    await Session.save(jsonDecode(r.body));
  }

  static Future<List<dynamic>> reports() async {
    final r = await http.get(Uri.parse('$baseUrl/reports/'), headers: _headers);
    _check(r);
    return jsonDecode(r.body);
  }

  static Future<Map<String, dynamic>> stats() async {
    final r =
        await http.get(Uri.parse('$baseUrl/reports/stats/'), headers: _headers);
    _check(r);
    return jsonDecode(r.body);
  }

  static Future<void> createReport(Map<String, String> data) async {
    final r = await http.post(Uri.parse('$baseUrl/reports/'),
        headers: _headers, body: jsonEncode(data));
    _check(r);
  }

  static Future<void> updateReport(int id, String status, String note) async {
    final r = await http.patch(Uri.parse('$baseUrl/reports/$id/'),
        headers: _headers,
        body: jsonEncode({'status': status, 'admin_note': note}));
    _check(r);
  }

  static void _check(http.Response r) {
    if (r.statusCode < 400) return;
    String msg = 'Something went wrong (${r.statusCode}).';
    try {
      final body = jsonDecode(r.body);
      if (body is Map) msg = body.values.join('\n').replaceAll(RegExp(r'[\[\]]'), '');
    } catch (_) {}
    throw Exception(msg);
  }
}
