// ============================================================
// lib/services/api_service.dart
// Central HTTP client — handles auth headers, errors, base URL
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'auth_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  static const _timeout = Duration(seconds: 15);

  // ----------------------------------------------------------------
  // Build headers (with optional auth token)
  // ----------------------------------------------------------------
  static Future<Map<String, String>> _headers() async {
    final token = await AuthStorage.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ----------------------------------------------------------------
  // Parse response and throw ApiException on error
  // ----------------------------------------------------------------
  static Map<String, dynamic> _parse(http.Response res) {
    Map<String, dynamic> body;
    try {
      body = json.decode(res.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Server returned invalid JSON.', statusCode: res.statusCode);
    }

    if (body['status'] == 'error') {
      throw ApiException(
        body['message'] ?? 'An error occurred.',
        statusCode: res.statusCode,
        errors: body['errors'] as Map<String, dynamic>?,
      );
    }
    return body;
  }

  // ----------------------------------------------------------------
  // HTTP verbs
  // ----------------------------------------------------------------
  static Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? query}) async {
    final uri = _buildUri(endpoint, query);
    debugPrint('[GET] $uri');
    try {
      final res = await http.get(uri, headers: await _headers()).timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    } on HttpException {
      throw ApiException('Network error.');
    }
  }

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final uri = _buildUri(endpoint);
    debugPrint('[POST] $uri  body=$body');
    try {
      final res = await http
          .post(uri, headers: await _headers(), body: json.encode(body))
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    final uri = _buildUri(endpoint);
    try {
      final res = await http
          .put(uri, headers: await _headers(), body: json.encode(body))
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  static Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = _buildUri(endpoint);
    try {
      final res = await http
          .patch(uri, headers: await _headers(), body: json.encode(body))
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint, Map<String, dynamic> body) async {
    final uri = _buildUri(endpoint);
    try {
      final res = await http
          .delete(uri, headers: await _headers(), body: json.encode(body))
          .timeout(_timeout);
      return _parse(res);
    } on SocketException {
      throw ApiException('No internet connection.');
    }
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------
  static Uri _buildUri(String endpoint, [Map<String, String>? query]) {
    final base = Uri.parse('$kApiBaseUrl/$endpoint');
    if (query == null || query.isEmpty) return base;
    return base.replace(queryParameters: {...base.queryParameters, ...query});
  }
}
