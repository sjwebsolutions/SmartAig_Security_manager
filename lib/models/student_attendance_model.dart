class ScannerInfo {
  final String appRole;
  final String scannerRole;
  final int userId;
  final String userName;

  ScannerInfo({
    required this.appRole,
    required this.scannerRole,
    required this.userId,
    required this.userName,
  });

  factory ScannerInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return ScannerInfo(
      appRole: json['app_role']?.toString() ?? '',
      scannerRole: json['scanner_role']?.toString() ?? '',
      userId: parseInt(json['user_id']),
      userName: json['user_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_role': appRole,
      'scanner_role': scannerRole,
      'user_id': userId,
      'user_name': userName,
    };
  }
}

class AttendanceStats {
  final int scannedByMeToday;
  final int totalPresentToday;

  AttendanceStats({
    required this.scannedByMeToday,
    required this.totalPresentToday,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return AttendanceStats(
      scannedByMeToday: parseInt(json['scanned_by_me_today']),
      totalPresentToday: parseInt(json['total_present_today']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scanned_by_me_today': scannedByMeToday,
      'total_present_today': totalPresentToday,
    };
  }
}

class StudentAttendanceData {
  final bool qrAttendanceEnabled;
  final bool canScan;
  final String? permissionMessage;
  final bool autoAbsentEnabled;
  final String autoAbsentCutoffTime;
  final ScannerInfo? scannerInfo;
  final AttendanceStats? stats;

  StudentAttendanceData({
    required this.qrAttendanceEnabled,
    required this.canScan,
    this.permissionMessage,
    required this.autoAbsentEnabled,
    required this.autoAbsentCutoffTime,
    this.scannerInfo,
    this.stats,
  });

  factory StudentAttendanceData.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      return val?.toString().toLowerCase() == 'true' || val?.toString() == '1';
    }

    return StudentAttendanceData(
      qrAttendanceEnabled: parseBool(json['qr_attendance_enabled']),
      canScan: parseBool(json['can_scan']),
      permissionMessage: json['permission_message']?.toString(),
      autoAbsentEnabled: parseBool(json['auto_absent_enabled']),
      autoAbsentCutoffTime: json['auto_absent_cutoff_time']?.toString() ?? '',
      scannerInfo: json['scanner_info'] is Map<String, dynamic>
          ? ScannerInfo.fromJson(json['scanner_info'] as Map<String, dynamic>)
          : null,
      stats: json['stats'] is Map<String, dynamic>
          ? AttendanceStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'qr_attendance_enabled': qrAttendanceEnabled,
      'can_scan': canScan,
      'permission_message': permissionMessage,
      'auto_absent_enabled': autoAbsentEnabled,
      'auto_absent_cutoff_time': autoAbsentCutoffTime,
      'scanner_info': scannerInfo?.toJson(),
      'stats': stats?.toJson(),
    };
  }
}

class StudentAttendanceResponseModel {
  final bool success;
  final String? message;
  final StudentAttendanceData? data;

  StudentAttendanceResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory StudentAttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      return val?.toString().toLowerCase() == 'true' || val?.toString() == '1';
    }

    return StudentAttendanceResponseModel(
      success: parseBool(json['success']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? StudentAttendanceData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

// ==================== SCAN MODELS ====================

class StudentQrScanRequestModel {
  final String qrPayload;
  final String sourceApp;

  StudentQrScanRequestModel({
    required this.qrPayload,
    this.sourceApp = 'android',
  });

  Map<String, dynamic> toJson() {
    return {
      'qr_payload': qrPayload,
      'source_app': sourceApp,
    };
  }
}

class StudentInfo {
  final int id;
  final String studentUniqueId;
  final String studentName;
  final String? studentNamePunjabi;
  final String? rollNo;
  final String admissionNumber;
  final int? classId;
  final String className;
  final int? sectionId;
  final String sectionName;
  final int? streamId;
  final String? streamName;
  final String gender;
  final String fatherName;
  final String fatherMobile;
  final String profileImage;

  StudentInfo({
    required this.id,
    required this.studentUniqueId,
    required this.studentName,
    this.studentNamePunjabi,
    this.rollNo,
    required this.admissionNumber,
    this.classId,
    required this.className,
    this.sectionId,
    required this.sectionName,
    this.streamId,
    this.streamName,
    required this.gender,
    required this.fatherName,
    required this.fatherMobile,
    required this.profileImage,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return StudentInfo(
      id: parseInt(json['id']),
      studentUniqueId: json['student_unique_id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      studentNamePunjabi: json['student_name_punjabi']?.toString(),
      rollNo: json['roll_no']?.toString(),
      admissionNumber: json['admission_number']?.toString() ?? '',
      classId: json['class_id'] != null ? parseInt(json['class_id']) : null,
      className: json['class_name']?.toString() ?? '',
      sectionId: json['section_id'] != null ? parseInt(json['section_id']) : null,
      sectionName: json['section_name']?.toString() ?? '',
      streamId: json['stream_id'] != null ? parseInt(json['stream_id']) : null,
      streamName: json['stream_name']?.toString(),
      gender: json['gender']?.toString() ?? '',
      fatherName: json['father_name']?.toString() ?? '',
      fatherMobile: json['father_mobile']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
    );
  }
}

class AttendanceDetails {
  final int id;
  final String status;
  final String date;
  final String punchTime;
  final String attendanceMode;
  final String markedVia;
  final String takenByName;
  final String takenByRole;
  final String? remarks;

  AttendanceDetails({
    required this.id,
    required this.status,
    required this.date,
    required this.punchTime,
    required this.attendanceMode,
    required this.markedVia,
    required this.takenByName,
    required this.takenByRole,
    this.remarks,
  });

  factory AttendanceDetails.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return AttendanceDetails(
      id: parseInt(json['id']),
      status: json['status']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      punchTime: json['punch_time']?.toString() ?? '',
      attendanceMode: json['attendance_mode']?.toString() ?? '',
      markedVia: json['marked_via']?.toString() ?? '',
      takenByName: json['taken_by_name']?.toString() ?? '',
      takenByRole: json['taken_by_role']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
    );
  }
}

class StudentScanData {
  final StudentInfo? student;
  final AttendanceDetails? attendance;
  final bool onLeaveWarning;
  final dynamic leaveDetails;

  StudentScanData({
    this.student,
    this.attendance,
    required this.onLeaveWarning,
    this.leaveDetails,
  });

  factory StudentScanData.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      return val?.toString().toLowerCase() == 'true' || val?.toString() == '1';
    }

    return StudentScanData(
      student: json['student'] is Map<String, dynamic>
          ? StudentInfo.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      attendance: json['attendance'] is Map<String, dynamic>
          ? AttendanceDetails.fromJson(json['attendance'] as Map<String, dynamic>)
          : null,
      onLeaveWarning: parseBool(json['on_leave_warning']),
      leaveDetails: json['leave_details'],
    );
  }
}

class StudentScanResponseModel {
  final bool success;
  final bool alreadyMarked;
  final String message;
  final StudentScanData? data;

  StudentScanResponseModel({
    required this.success,
    required this.alreadyMarked,
    required this.message,
    this.data,
  });

  factory StudentScanResponseModel.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic val) {
      if (val is bool) return val;
      if (val is int) return val == 1;
      return val?.toString().toLowerCase() == 'true' || val?.toString() == '1';
    }

    return StudentScanResponseModel(
      success: parseBool(json['success']),
      alreadyMarked: parseBool(json['already_marked']),
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? StudentScanData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
