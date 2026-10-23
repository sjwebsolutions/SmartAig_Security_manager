import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:security_manager/models/visitor_model.dart';

class VisitorService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  /// Get list of visitors
  Future<VisitorResponseModel> getVisitors(String token) async {
    final url = Uri.parse('$baseUrl/gate-keeper/visitors');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return VisitorResponseModel.fromJson(responseData);
      } else {
        String message;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          message = responseData['message'] ?? _getErrorMessage(response.statusCode);
        } catch (_) {
          message = _getErrorMessage(response.statusCode);
        }
        throw message;
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Create visitor check-in entry
  Future<CreateVisitorResponseModel> createVisitor({
    required String token,
    required CreateVisitorRequestModel request,
  }) async {
    final url = Uri.parse('$baseUrl/gate-keeper/visitors');
    try {
      debugPrint('--- Create Visitor Request Sent ---');
      debugPrint('URL: $url');
      debugPrint('Body: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      debugPrint('--- Create Visitor Response (${response.statusCode}) ---');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return CreateVisitorResponseModel.fromJson(responseData);
      } else {
        String message;
        try {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          message = responseData['message'] ?? _getErrorMessage(response.statusCode);
        } catch (_) {
          message = _getErrorMessage(response.statusCode);
        }
        throw message;
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check all details.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Endpoint not found (404). Please contact support.';
      case 422:
        return 'Validation failed. Please verify your input.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. Please try again. (Status: $statusCode)';
    }
  }

  String _handleException(dynamic e) {
    if (e is String) return e;
    if (e.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (e.toString().contains('TimeoutException')) {
      return 'Connection timed out. Please try again.';
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
