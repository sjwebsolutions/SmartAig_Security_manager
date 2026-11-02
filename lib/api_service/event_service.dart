import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:security_manager/models/event_scan_model.dart';

class EventService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  /// Get today's event scan records
  Future<EventScanResponseModel> getTodayScans(String token) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/passes/today-scans');
    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      // Fallback if 404
      if (response.statusCode == 404) {
        final fallbackUrl = Uri.parse('$baseUrl/events/passes/today-scans');
        final fallbackResponse = await http.get(
          fallbackUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));

        if (fallbackResponse.statusCode != 404) {
          response = fallbackResponse;
        }
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return EventScanResponseModel.fromJson(responseData);
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

  /// Scan / Validate an Event Pass QR code
  Future<EventPassScanResponseModel> scanEventPass({
    required String token,
    required String qrPayload,
    String gateName = 'Gate 1 - Main Entrance',
  }) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/passes/scan');
    try {
      final bodyData = {
        'qr_payload': qrPayload,
        'gate_name': gateName,
      };

      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        final fallbackUrl = Uri.parse('$baseUrl/events/passes/scan');
        final fallbackResponse = await http.post(
          fallbackUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(bodyData),
        ).timeout(const Duration(seconds: 15));

        if (fallbackResponse.statusCode != 404) {
          response = fallbackResponse;
        }
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return EventPassScanResponseModel.fromJson(responseData);
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Check-in Event Pass
  Future<EventCheckInResponseModel> checkInEventPass({
    required String token,
    required EventCheckInRequestModel request,
  }) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/passes/check-in');
    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        final fallbackUrl = Uri.parse('$baseUrl/events/passes/check-in');
        final fallbackResponse = await http.post(
          fallbackUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(request.toJson()),
        ).timeout(const Duration(seconds: 15));

        if (fallbackResponse.statusCode != 404) {
          response = fallbackResponse;
        }
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return EventCheckInResponseModel.fromJson(responseData);
    } catch (e) {
      throw _handleException(e);
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please try again.';
      case 401:
        return 'Session expired. Please login again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return 'Endpoint not found (404). Please contact support.';
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
