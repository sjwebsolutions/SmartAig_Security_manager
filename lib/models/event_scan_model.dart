class EventScanResponseModel {
  final bool success;
  final String message;
  final EventScanDataModel? data;

  EventScanResponseModel({
    required this.success,
    this.message = '',
    this.data,
  });

  factory EventScanResponseModel.fromJson(Map<String, dynamic> json) {
    return EventScanResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EventScanDataModel.fromJson(json['data'] as Map<String, dynamic>)
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

class EventScanDataModel {
  final int totalValidScansToday;
  final List<EventScanItemModel> scans;

  EventScanDataModel({
    required this.totalValidScansToday,
    required this.scans,
  });

  factory EventScanDataModel.fromJson(Map<String, dynamic> json) {
    var list = json['scans'] as List? ?? [];
    List<EventScanItemModel> scanItems =
        list.map((i) => EventScanItemModel.fromJson(i as Map<String, dynamic>)).toList();

    return EventScanDataModel(
      totalValidScansToday: json['total_valid_scans_today'] as int? ?? 0,
      scans: scanItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_valid_scans_today': totalValidScansToday,
      'scans': scans.map((s) => s.toJson()).toList(),
    };
  }
}

class EventScanItemModel {
  final int id;
  final String passNumber;
  final String eventTitle;
  final String studentName;
  final String admissionNo;
  final String classSection;
  final String scanStatus;
  final String scanMessage;
  final String gateName;
  final String scannedBy;
  final String scannedAt;
  final String scannedAtFull;

  EventScanItemModel({
    required this.id,
    required this.passNumber,
    required this.eventTitle,
    required this.studentName,
    required this.admissionNo,
    required this.classSection,
    required this.scanStatus,
    required this.scanMessage,
    required this.gateName,
    required this.scannedBy,
    required this.scannedAt,
    required this.scannedAtFull,
  });

  factory EventScanItemModel.fromJson(Map<String, dynamic> json) {
    return EventScanItemModel(
      id: json['id'] as int? ?? 0,
      passNumber: json['pass_number'] as String? ?? '',
      eventTitle: json['event_title'] as String? ?? '',
      studentName: json['student_name'] as String? ?? '',
      admissionNo: json['admission_no'] as String? ?? '',
      classSection: json['class_section'] as String? ?? '',
      scanStatus: json['scan_status'] as String? ?? '',
      scanMessage: json['scan_message'] as String? ?? '',
      gateName: json['gate_name'] as String? ?? '',
      scannedBy: json['scanned_by'] as String? ?? '',
      scannedAt: json['scanned_at'] as String? ?? '',
      scannedAtFull: json['scanned_at_full'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pass_number': passNumber,
      'event_title': eventTitle,
      'student_name': studentName,
      'admission_no': admissionNo,
      'class_section': classSection,
      'scan_status': scanStatus,
      'scan_message': scanMessage,
      'gate_name': gateName,
      'scanned_by': scannedBy,
      'scanned_at': scannedAt,
      'scanned_at_full': scannedAtFull,
    };
  }
}

// ==========================================
// EVENT PASS SCAN RESULT MODELS
// ==========================================

class EventPassScanResponseModel {
  final bool success;
  final String message;
  final bool isAlreadyCheckedIn;
  final bool canCheckin;
  final String warning;
  final EventPassScanData? data;

  EventPassScanResponseModel({
    required this.success,
    this.message = '',
    this.isAlreadyCheckedIn = false,
    this.canCheckin = false,
    this.warning = '',
    this.data,
  });

  factory EventPassScanResponseModel.fromJson(Map<String, dynamic> json) {
    return EventPassScanResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      isAlreadyCheckedIn: json['is_already_checked_in'] as bool? ?? false,
      canCheckin: json['can_checkin'] as bool? ?? false,
      warning: json['warning'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EventPassScanData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EventPassScanData {
  final EventPassModel? pass;
  final EventDetailModel? event;
  final EventStudentModel? student;
  final List<EventAttendeeModel> approvedAttendees;
  final List<EventAttendeeModel> rejectedAttendees;

  EventPassScanData({
    this.pass,
    this.event,
    this.student,
    this.approvedAttendees = const [],
    this.rejectedAttendees = const [],
  });

  factory EventPassScanData.fromJson(Map<String, dynamic> json) {
    var approvedList = json['approved_attendees'] as List? ?? [];
    var rejectedList = json['rejected_attendees'] as List? ?? [];

    return EventPassScanData(
      pass: json['pass'] != null && json['pass'] is Map<String, dynamic>
          ? EventPassModel.fromJson(json['pass'] as Map<String, dynamic>)
          : null,
      event: json['event'] != null && json['event'] is Map<String, dynamic>
          ? EventDetailModel.fromJson(json['event'] as Map<String, dynamic>)
          : null,
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? EventStudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      approvedAttendees: approvedList
          .map((i) => EventAttendeeModel.fromJson(i as Map<String, dynamic>))
          .toList(),
      rejectedAttendees: rejectedList
          .map((i) => EventAttendeeModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EventPassModel {
  final int id;
  final String uuid;
  final String passNumber;
  final String approvalStatus;
  final String checkinStatus;
  final String firstCheckinAt;
  final int totalAttendeesRequested;
  final int totalAttendeesApproved;
  final int totalCheckedIn;
  final int totalRemaining;

  EventPassModel({
    required this.id,
    required this.uuid,
    required this.passNumber,
    required this.approvalStatus,
    required this.checkinStatus,
    required this.firstCheckinAt,
    required this.totalAttendeesRequested,
    required this.totalAttendeesApproved,
    required this.totalCheckedIn,
    required this.totalRemaining,
  });

  factory EventPassModel.fromJson(Map<String, dynamic> json) {
    return EventPassModel(
      id: json['id'] as int? ?? 0,
      uuid: json['uuid'] as String? ?? '',
      passNumber: json['pass_number'] as String? ?? '',
      approvalStatus: json['approval_status'] as String? ?? '',
      checkinStatus: json['checkin_status'] as String? ?? '',
      firstCheckinAt: json['first_checkin_at'] as String? ?? '',
      totalAttendeesRequested: json['total_attendees_requested'] as int? ?? 0,
      totalAttendeesApproved: json['total_attendees_approved'] as int? ?? 0,
      totalCheckedIn: json['total_checked_in'] as int? ?? 0,
      totalRemaining: json['total_remaining'] as int? ?? 0,
    );
  }
}

class EventDetailModel {
  final int id;
  final String title;
  final String venue;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;

  EventDetailModel({
    required this.id,
    required this.title,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) {
    return EventDetailModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      venue: json['venue'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      startTime: json['start_time'] as String? ?? '',
      endTime: json['end_time'] as String? ?? '',
    );
  }
}

class EventStudentModel {
  final int id;
  final String studentName;
  final String? studentNamePunjabi;
  final String admissionNumber;
  final String rollNo;
  final String studentUniqueId;
  final String className;
  final String section;
  final String classSection;
  final String fatherName;
  final String fatherMobile;
  final String motherName;
  final String motherMobile;
  final String? photoUrl;

  EventStudentModel({
    required this.id,
    required this.studentName,
    this.studentNamePunjabi,
    required this.admissionNumber,
    required this.rollNo,
    required this.studentUniqueId,
    required this.className,
    required this.section,
    required this.classSection,
    required this.fatherName,
    required this.fatherMobile,
    required this.motherName,
    required this.motherMobile,
    this.photoUrl,
  });

  factory EventStudentModel.fromJson(Map<String, dynamic> json) {
    return EventStudentModel(
      id: json['id'] as int? ?? 0,
      studentName: json['student_name'] as String? ?? '',
      studentNamePunjabi: json['student_name_punjabi'] as String?,
      admissionNumber: json['admission_number'] as String? ?? '',
      rollNo: json['roll_no'] as String? ?? '',
      studentUniqueId: json['student_unique_id'] as String? ?? '',
      className: json['class'] as String? ?? '',
      section: json['section'] as String? ?? '',
      classSection: json['class_section'] as String? ?? '',
      fatherName: json['father_name'] as String? ?? '',
      fatherMobile: json['father_mobile'] as String? ?? '',
      motherName: json['mother_name'] as String? ?? '',
      motherMobile: json['mother_mobile'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
    );
  }
}

class EventAttendeeModel {
  final int id;
  final String name;
  final String personType;
  final String mobileNo;
  final String maskedAadhaar;
  final String? photoUrl;
  final bool isCheckedIn;
  final String? checkedInAt;

  EventAttendeeModel({
    required this.id,
    required this.name,
    required this.personType,
    required this.mobileNo,
    required this.maskedAadhaar,
    this.photoUrl,
    required this.isCheckedIn,
    this.checkedInAt,
  });

  factory EventAttendeeModel.fromJson(Map<String, dynamic> json) {
    return EventAttendeeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      personType: json['person_type'] as String? ?? '',
      mobileNo: json['mobile_no'] as String? ?? '',
      maskedAadhaar: json['masked_aadhaar'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      isCheckedIn: json['is_checked_in'] as bool? ?? false,
      checkedInAt: json['checked_in_at'] as String?,
    );
  }
}

// ==========================================
// EVENT CHECK-IN MODELS
// ==========================================

class EventCheckInRequestModel {
  final int passId;
  final List<int> attendeeIds;
  final String gateName;
  final String remarks;

  EventCheckInRequestModel({
    required this.passId,
    this.attendeeIds = const [],
    this.gateName = '1',
    this.remarks = '',
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'pass_id': passId,
      'gate_name': gateName,
    };
    if (attendeeIds.isNotEmpty) {
      data['attendee_ids'] = attendeeIds;
    } else {
      data['attendee_ids'] = [];
    }
    if (remarks.isNotEmpty) {
      data['remarks'] = remarks;
    }
    return data;
  }
}

class EventCheckInResponseModel {
  final bool success;
  final String message;
  final EventCheckInDataModel? data;

  EventCheckInResponseModel({
    required this.success,
    this.message = '',
    this.data,
  });

  factory EventCheckInResponseModel.fromJson(Map<String, dynamic> json) {
    return EventCheckInResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? EventCheckInDataModel.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class EventCheckInDataModel {
  final String passNumber;
  final String checkinStatus;
  final int admittedCount;
  final List<String> admittedAttendees;
  final int totalCheckedIn;
  final int totalApproved;
  final String checkedInAt;
  final String gateName;

  EventCheckInDataModel({
    required this.passNumber,
    required this.checkinStatus,
    required this.admittedCount,
    required this.admittedAttendees,
    required this.totalCheckedIn,
    required this.totalApproved,
    required this.checkedInAt,
    required this.gateName,
  });

  factory EventCheckInDataModel.fromJson(Map<String, dynamic> json) {
    var list = json['admitted_attendees'] as List? ?? [];
    List<String> attendees = list.map((e) => e.toString()).toList();

    return EventCheckInDataModel(
      passNumber: json['pass_number'] as String? ?? '',
      checkinStatus: json['checkin_status'] as String? ?? '',
      admittedCount: json['admitted_count'] as int? ?? 0,
      admittedAttendees: attendees,
      totalCheckedIn: json['total_checked_in'] as int? ?? 0,
      totalApproved: json['total_approved'] as int? ?? 0,
      checkedInAt: json['checked_in_at'] as String? ?? '',
      gateName: json['gate_name'] as String? ?? '',
    );
  }
}
