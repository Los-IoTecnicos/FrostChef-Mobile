import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> register(
      String firstName,
      String lastName,
      String email,
      String password,
      String phone,
      bool acceptTerms,
      ) async {
    const url = 'http://192.168.0.10:8088/api/v1/auth/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'password': password,
          'phone': phone,
          'acceptTerms': acceptTerms.toString(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        _isAuthenticated = true;
        notifyListeners();
      } else {
        print('Error: ${response.statusCode}');
        print('Response Body: ${response.body}');
        throw Exception('Failed to register: ${response.statusCode}');
      }

    } catch (e) {
      // manejo de excepciones
      print('Error during registration: $e');
      throw Exception('Failed to register: $e');
    }
  }


  Future<void> sendVerificationCode(String email) async {
    final url = 'http://192.168.0.10:8088/api/v1/auth/authenticate';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send verification code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }


  Future<void> verifyCode(String email, String code) async {

    final url = 'http://192.168.0.10:8088/api/v1/auth/activate-account';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to verify code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to verify code: $e');
    }
  }


  Future<void> login(String email, String password) async {
    final url = 'http://192.168.0.10:8088/api/v1/auth/authenticate';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        _isAuthenticated = true;
        notifyListeners();
      } else {
        final errorMessage = responseBody['message'] ?? 'Failed to login';
        if (response.statusCode == 401) {
          throw Exception('Unauthorized: $errorMessage');
        } else {
          throw Exception('Login failed: $errorMessage');
        }
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }


  Future<void> recoverPassword(String email) async {
    final url = 'http://192.168.0.10:8088/api/v1/auth/generate-password-reset-code';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send recovery email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send recovery email: $e');
    }
  }

  Future<void> updatePassword(String email, String token, String newPassword) async {
    final url = '192.168.0.10:8088/api/v1/auth/reset-password';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update password: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  Future<void> logout() async {

    _isAuthenticated = false;
    notifyListeners();
  }

}
