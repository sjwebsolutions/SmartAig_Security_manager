class AttendanceClockRequestModel {
  final String qrToken;
  final double latitude;
  final double longitude;
  final String? action;

  AttendanceClockRequestModel({
    required this.qrToken,
    required this.latitude,
    required this.longitude,
    this.action,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'qr_token': qrToken,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (action != null && action!.isNotEmpty) {
      data['action'] = action;
    }
    return data;
  }
}

class AttendanceClockData {
  final String? clockIn;
  final String? clockOut;
  final String? status;
  final String? attendanceValue;

  AttendanceClockData({
    this.clockIn,
    this.clockOut,
    this.status,
    this.attendanceValue,
  });

  factory AttendanceClockData.fromJson(Map<String, dynamic> json) {
    return AttendanceClockData(
      clockIn: json['clock_in']?.toString() ?? json['clock_in_time']?.toString() ?? json['in_time']?.toString(),
      clockOut: json['clock_out']?.toString() ?? json['clock_out_time']?.toString() ?? json['out_time']?.toString(),
      status: json['status']?.toString() ?? json['attendance_status']?.toString(),
      attendanceValue: json['attendance_value']?.toString(),
    );
  }
}

class AttendanceClockResponseModel {
  final bool success;
  final String message;
  final AttendanceClockData? data;

  AttendanceClockResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AttendanceClockResponseModel.fromJson(Map<String, dynamic> json) {
    AttendanceClockData? parsedData;
    if (json['data'] is Map<String, dynamic>) {
      parsedData = AttendanceClockData.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json['attendance'] is Map<String, dynamic>) {
      parsedData = AttendanceClockData.fromJson(json['attendance'] as Map<String, dynamic>);
    }

    return AttendanceClockResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: parsedData,
    );
  }
}
