// ============================================================
// lib/providers/auth_provider.dart
// Manages auth state: login, register, logout, current user
// ============================================================

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class UserData {
  final int id;
  final String name;
  final String email;
  final String? avatar;

  UserData({required this.id, required this.name, required this.email, this.avatar});

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id:     int.tryParse(json['id'].toString()) ?? 0,
        name:   json['name'] ?? '',
        email:  json['email'] ?? '',
        avatar: json['avatar'],
      );
}

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  UserData?  _user;
  String?    _error;
  bool       _loading = false;

  AuthStatus get status  => _status;
  UserData?  get user    => _user;
  String?    get error   => _error;
  bool       get loading => _loading;
  bool       get isAuth  => _status == AuthStatus.authenticated;

  // ----------------------------------------------------------------
  // Boot: check persisted token
  // ----------------------------------------------------------------
  Future<void> init() async {
    final loggedIn = await AuthStorage.isLoggedIn();
    if (loggedIn) {
      final cached = await AuthStorage.getUser();
      if (cached != null) {
        _user   = UserData.fromJson(cached);
        _status = AuthStatus.authenticated;
        notifyListeners();
      }
      // Verify token is still valid
      try {
        final res  = await ApiService.get('auth.php', query: {'action': 'me'});
        final data = res['data'] as Map<String, dynamic>;
        _user   = UserData.fromJson(data);
        _status = AuthStatus.authenticated;
        await AuthStorage.saveUser(data);
      } catch (_) {
        await _clearSession();
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ----------------------------------------------------------------
  // Register
  // ----------------------------------------------------------------
  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      final res  = await ApiService.post('auth.php?action=register', {
        'name': name, 'email': email, 'password': password,
      });
      return await _handleAuthResponse(res);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ----------------------------------------------------------------
  // Login
  // ----------------------------------------------------------------
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final res = await ApiService.post('auth.php?action=login', {
        'email': email, 'password': password,
      });
      return await _handleAuthResponse(res);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ----------------------------------------------------------------
  // Update Profile
  // ----------------------------------------------------------------
  Future<bool> updateProfile(String name) async {
    _setLoading(true);
    try {
      final res = await ApiService.patch('auth.php?action=update_profile', {
        'name': name,
      });
      final data = res['data'] as Map<String, dynamic>;
      _user = UserData.fromJson(data);
      await AuthStorage.saveUser(data);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ----------------------------------------------------------------
  // Change Password
  // ----------------------------------------------------------------
  Future<bool> changePassword(String oldPass, String newPass) async {
    _setLoading(true);
    try {
      await ApiService.patch('auth.php?action=change_password', {
        'old_password': oldPass,
        'new_password': newPass,
      });
      _error = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ----------------------------------------------------------------
  // Logout
  // ----------------------------------------------------------------
  Future<void> logout() async {
    _setLoading(true);
    try {
      await ApiService.post('auth.php?action=logout', {});
    } catch (_) {}
    await _clearSession();
    _setLoading(false);
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------
  Future<bool> _handleAuthResponse(Map<String, dynamic> res) async {
    final data  = res['data'] as Map<String, dynamic>;
    final token = data['token'] as String;
    final user  = data['user']  as Map<String, dynamic>;

    await AuthStorage.saveToken(token);
    await AuthStorage.saveUser(user);
    _user   = UserData.fromJson(user);
    _status = AuthStatus.authenticated;
    _error  = null;
    notifyListeners();
    return true;
  }

  Future<void> _clearSession() async {
    await AuthStorage.clear();
    _user   = null;
    _status = AuthStatus.unauthenticated;
    _error  = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}
