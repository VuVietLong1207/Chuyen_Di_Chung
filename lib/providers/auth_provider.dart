import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Mock login – replace with API call in production
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _userEmail = email;
    _userName = email.split('@')[0];
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', email);
    await prefs.setString('userName', _userName);
    notifyListeners();
  }

  Future<void> register(String username, String email, String password, String phone) async {
    // Mock register – replace with API call
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _userName = username;
    _userEmail = email;
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userName', username);
    await prefs.setString('userEmail', email);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    await prefs.clear();
    notifyListeners();
  }
}