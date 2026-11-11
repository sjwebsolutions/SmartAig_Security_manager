import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:security_manager/models/active_event_model.dart';
import 'package:security_manager/models/create_event_pass_model.dart';
import 'package:security_manager/models/event_pass_application_model.dart';
import 'package:security_manager/models/event_scan_model.dart';
import 'package:security_manager/models/student_search_model.dart';

class EventService {
  static const String baseUrl = 'https://smartaig.com/api/v1';

  /// Get active events list (events/active)
  Future<ActiveEventResponseModel> getActiveEvents(String token) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/active');
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
        final fallbackUrl = Uri.parse('$baseUrl/events/active');
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
        return ActiveEventResponseModel.fromJson(responseData);
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

  /// Search Students for an Event Pass (events/passes/search-students?event_id=13&query=...)
  Future<StudentSearchResponseModel> searchStudents({
    required String token,
    required int eventId,
    String query = '',
  }) async {
    final queryParams = {
      'event_id': eventId.toString(),
      if (query.isNotEmpty) 'query': query,
    };
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/passes/search-students').replace(queryParameters: queryParams);
    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        final fallbackUrl = Uri.parse('$baseUrl/events/passes/search-students').replace(queryParameters: queryParams);
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
        return StudentSearchResponseModel.fromJson(responseData);
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

  /// Get Event Pass Applications list (events/passes/applications?event_id=1&page=1)
  Future<EventPassApplicationResponseModel> getPassApplications({
    required String token,
    int? eventId,
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      if (eventId != null) 'event_id': eventId.toString(),
      'page': page.toString(),
    };
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/passes/applications').replace(queryParameters: queryParams);
    try {
      var response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        final fallbackUrl = Uri.parse('$baseUrl/events/passes/applications').replace(queryParameters: queryParams);
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
        return EventPassApplicationResponseModel.fromJson(responseData);
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

  /// Update Event Pass Status (Approve / Reject)
  Future<UpdatePassStatusResponseModel> updatePassStatus({
    required String token,
    required UpdatePassStatusRequestModel request,
  }) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/passes/update-status');
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
        final fallbackUrl = Uri.parse('$baseUrl/events/passes/update-status');
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
      return UpdatePassStatusResponseModel.fromJson(responseData);
    } catch (e) {
      throw _handleException(e);
    }
  }

  /// Issue Walk-In Event Pass (events/passes/issue-walk-in)
  Future<IssueWalkInPassResponseModel> issueWalkInPass({
    required String token,
    required IssueWalkInPassRequestModel request,
  }) async {
    Uri url = Uri.parse('$baseUrl/gate-keeper/events/passes/issue-walk-in');

    Future<http.Response> sendMultipart(Uri reqUrl) async {
      var mpRequest = http.MultipartRequest('POST', reqUrl);
      mpRequest.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      mpRequest.fields['event_id'] = request.eventId.toString();
      mpRequest.fields['student_id'] = request.studentId.toString();
      mpRequest.fields['auto_approve'] = request.autoApprove ? 'true' : 'false';
      mpRequest.fields['auto_checkin'] = request.autoCheckin ? 'true' : 'false';
      mpRequest.fields['gate_name'] = request.gateName;
      mpRequest.fields['remarks'] = request.remarks;
      mpRequest.fields['attendees'] = request.attendees.length.toString();

      for (int i = 0; i < request.attendees.length; i++) {
        final att = request.attendees[i];
        mpRequest.fields['attendees[$i][person_type]'] = att.personType;
        mpRequest.fields['attendees[$i][name]'] = att.name;
        mpRequest.fields['attendees[$i][mobile_no]'] = att.mobileNo;
        mpRequest.fields['attendees[$i][whatsapp_no]'] = att.whatsappNo;
        mpRequest.fields['attendees[$i][aadhaar_number]'] = att.aadhaarNumber;
        if (att.existingPhotoPath != null && att.existingPhotoPath!.isNotEmpty) {
          mpRequest.fields['attendees[$i][existing_photo_path]'] = att.existingPhotoPath!;
        }

        if (att.photoFilePath != null && att.photoFilePath!.isNotEmpty) {
          mpRequest.files.add(
            await http.MultipartFile.fromPath(
              'attendees[$i][photo]',
              att.photoFilePath!,
            ),
          );
        }
      }

      var streamedResponse = await mpRequest.send().timeout(const Duration(seconds: 25));
      return await http.Response.fromStream(streamedResponse);
    }

    try {
      var response = await sendMultipart(url);

      if (response.statusCode == 404) {
        final fallbackUrl = Uri.parse('$baseUrl/events/passes/issue-walk-in');
        var fallbackResponse = await sendMultipart(fallbackUrl);
        if (fallbackResponse.statusCode != 404) {
          response = fallbackResponse;
        }
      }

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return IssueWalkInPassResponseModel.fromJson(responseData);
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
