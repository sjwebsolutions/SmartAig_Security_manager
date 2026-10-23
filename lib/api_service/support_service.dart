import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:security_manager/models/support_model.dart';

class SupportService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  Future<SupportResponseModel> getSupportSettings(String token) async {
    final url = Uri.parse('$baseUrl/gate-keeper/support-settings');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return SupportResponseModel.fromJson(responseData);
      } else {
        throw _getErrorMessage(response.statusCode);
      }
    } catch (e) {
      throw _handleException(e);
    }
  }

  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Session expired. Please login again.';
      case 404:
        return 'Support settings not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Something went wrong. (Status: $statusCode)';
    }
  }

  String _handleException(dynamic e) {
    if (e.toString().contains('SocketException')) {
      return 'No internet connection.';
    } else if (e.toString().contains('TimeoutException')) {
      return 'Connection timed out.';
    }
    return e.toString();
  }
}
