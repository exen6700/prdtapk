import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _currentUser;
  String? _currentEmail;
  String? _verificationCode;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;
  String? get currentEmail => _currentEmail;
  String? get verificationCode => _verificationCode;

  // Check authentication status on app start
  Future<void> checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final username = prefs.getString('username');
      final email = prefs.getString('email');

      if (token != null && username != null && email != null) {
        _currentUser = username;
        _currentEmail = email;
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      print('Auth status check error: $e');
    }
  }

  // User registration
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    print('🔍 DEBUG: Starting registration...');
    print('🔍 DEBUG: URL: ${AppConstants.registerUrl}');
    print('🔍 DEBUG: Username: $username');
    print('🔍 DEBUG: Email: $email');

    try {
      // Send registration request to Vercel API
      final response = await http.post(
        Uri.parse(AppConstants.registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('🔍 DEBUG: Response status: ${response.statusCode}');
      print('🔍 DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Send email verification code
          await sendVerificationCode(email);
          
          _isLoading = false;
          notifyListeners();
          
          return {
            'success': true,
            'message': AppConstants.registrationSuccessMessage,
          };
        } else {
          _isLoading = false;
          notifyListeners();
          
          return {
            'success': false,
            'message': data['message'] ?? 'Registration failed',
          };
        }
      } else {
        _isLoading = false;
        notifyListeners();
        
        return {
          'success': false,
          'message': AppConstants.serverErrorMessage,
        };
      }
    } catch (e) {
      print('🔍 DEBUG: Registration error: $e');
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': false,
        'message': AppConstants.networkErrorMessage,
      };
    }
  }

  // Send email verification code
  Future<bool> sendVerificationCode(String email, {String? username, Map<String, dynamic>? deviceInfo}) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.sendVerificationUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'username': username,
          'deviceInfo': deviceInfo ?? {
            'device': 'Flutter App',
            'os': 'Mobile',
            'ip': 'Unknown',
            'location': 'Unknown'
          }
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Send verification code error: $e');
      return false;
    }
  }

  // Verify code
  Future<Map<String, dynamic>> verifyCode({
    required String username,
    required String email,
    required String code,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppConstants.verifyCodeUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Save session information
          await _saveSession(data['user']);
          
          _isAuthenticated = true;
          _currentUser = data['user']['username'];
          _currentEmail = data['user']['email'];
          
          notifyListeners();
          
          return {
            'success': true,
            'message': AppConstants.verificationSuccessMessage,
            'user': data['user'],
          };
        } else {
          return {
            'success': false,
            'message': data['message'] ?? AppConstants.invalidVerificationCodeMessage,
          };
        }
      } else {
        return {
          'success': false,
          'message': AppConstants.serverErrorMessage,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': AppConstants.networkErrorMessage,
      };
    }
  }

  // User login - username can be either username or email
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    print('🔍 DEBUG: Starting login...');
    print('🔍 DEBUG: URL: ${AppConstants.loginUrl}');
    print('🔍 DEBUG: Username: $username');

    try {
      final response = await http.post(
        Uri.parse(AppConstants.loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      print('🔍 DEBUG: Login response status: ${response.statusCode}');
      print('🔍 DEBUG: Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Send email verification code
          await sendVerificationCode(data['user']['email']);
          
          _isLoading = false;
          notifyListeners();
          
          return {
            'success': true,
            'message': AppConstants.loginSuccessMessage,
            'email': data['user']['email'],
          };
        } else {
          _isLoading = false;
          notifyListeners();
          
          return {
            'success': false,
            'message': data['message'] ?? 'Login failed',
          };
        }
      } else {
        _isLoading = false;
        notifyListeners();
        
        return {
          'success': false,
          'message': AppConstants.serverErrorMessage,
        };
      }
    } catch (e) {
      print('🔍 DEBUG: Login error: $e');
      _isLoading = false;
      notifyListeners();
      
      return {
        'success': false,
        'message': AppConstants.networkErrorMessage,
      };
    }
  }

  // Save session information
  Future<void> _saveSession(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', user['token'] ?? '');
    await prefs.setString('username', user['username'] ?? '');
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('wallet_address', user['wallet_address'] ?? '');
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      _isAuthenticated = false;
      _currentUser = null;
      _currentEmail = null;
      
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Set verification code
  void setVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }
} 