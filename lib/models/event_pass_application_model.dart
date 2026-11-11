class EventPassApplicationResponseModel {
  final bool success;
  final String message;
  final List<EventPassApplicationModel> data;
  final int currentPage;
  final int perPage;
  final int totalCount;
  final int totalPages;

  EventPassApplicationResponseModel({
    required this.success,
    this.message = '',
    required this.data,
    this.currentPage = 1,
    this.perPage = 20,
    this.totalCount = 0,
    this.totalPages = 1,
  });

  factory EventPassApplicationResponseModel.fromJson(Map<String, dynamic> json) {
    List<EventPassApplicationModel> passList = [];

    dynamic rawData = json['data'];
    if (rawData != null && rawData is Map<String, dynamic> && rawData['data'] is List) {
      rawData = rawData['data'];
    }

    if (rawData != null && rawData is List) {
      passList = rawData
          .map((item) => EventPassApplicationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return EventPassApplicationResponseModel(
      success: json['success'] == true || json['success'] == 1,
      message: json['message']?.toString() ?? '',
      data: passList,
      currentPage: parseInt(json['current_page'] ?? (json['data'] is Map ? json['data']['current_page'] : null)),
      perPage: parseInt(json['per_page'] ?? (json['data'] is Map ? json['data']['per_page'] : null)),
      totalCount: parseInt(json['total_count'] ?? (json['data'] is Map ? json['data']['total_count'] : passList.length)),
      totalPages: parseInt(json['total_pages'] ?? (json['data'] is Map ? json['data']['total_pages'] : null)),
    );
  }
}

class EventPassApplicationModel {
  final int id;
  final String uuid;
  final String passNumber;
  final String approvalStatus;
  final String checkinStatus;
  final int totalAttendeesRequested;
  final int totalAttendeesApproved;
  final String createdAt;
  final String? actionAt;
  final String? actionByName;
  final String? actionByRole;
  final String? adminRemarks;
  final PassStudentModel? student;
  final List<PassAttendeeModel> attendees;

  EventPassApplicationModel({
    required this.id,
    required this.uuid,
    required this.passNumber,
    required this.approvalStatus,
    required this.checkinStatus,
    required this.totalAttendeesRequested,
    required this.totalAttendeesApproved,
    required this.createdAt,
    this.actionAt,
    this.actionByName,
    this.actionByRole,
    this.adminRemarks,
    this.student,
    required this.attendees,
  });

  factory EventPassApplicationModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    List<PassAttendeeModel> attList = [];
    if (json['attendees'] != null && json['attendees'] is List) {
      attList = (json['attendees'] as List)
          .map((item) => PassAttendeeModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return EventPassApplicationModel(
      id: parseInt(json['id']),
      uuid: json['uuid']?.toString() ?? '',
      passNumber: json['pass_number']?.toString() ?? json['pass_no']?.toString() ?? '',
      approvalStatus: json['approval_status']?.toString() ?? json['status']?.toString() ?? '',
      checkinStatus: json['checkin_status']?.toString() ?? '',
      totalAttendeesRequested: parseInt(json['total_attendees_requested']),
      totalAttendeesApproved: parseInt(json['total_attendees_approved']),
      createdAt: json['created_at']?.toString() ?? '',
      actionAt: json['action_at']?.toString(),
      actionByName: json['action_by_name']?.toString() ?? json['approved_by_name']?.toString(),
      actionByRole: json['action_by_role']?.toString(),
      adminRemarks: json['admin_remarks']?.toString() ?? json['remarks']?.toString(),
      student: json['student'] != null && json['student'] is Map<String, dynamic>
          ? PassStudentModel.fromJson(json['student'] as Map<String, dynamic>)
          : null,
      attendees: attList,
    );
  }
}

class PassStudentModel {
  final int id;
  final String name;
  final String admissionNumber;
  final String rollNo;
  final String className;
  final String section;
  final String? stream;
  final String? photoUrl;

  PassStudentModel({
    required this.id,
    required this.name,
    required this.admissionNumber,
    required this.rollNo,
    required this.className,
    required this.section,
    this.stream,
    this.photoUrl,
  });

  factory PassStudentModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return PassStudentModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? json['student_name']?.toString() ?? '',
      admissionNumber: json['admission_number']?.toString() ?? json['admission_no']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      className: json['class']?.toString() ?? json['class_name']?.toString() ?? '',
      section: json['section']?.toString() ?? json['section_name']?.toString() ?? '',
      stream: json['stream']?.toString() ?? json['stream_name']?.toString(),
      photoUrl: json['photo_url']?.toString() ?? json['student_photo_url']?.toString(),
    );
  }
}

class PassAttendeeModel {
  final int id;
  final String name;
  final String personType;
  final String mobileNo;
  final String whatsappNo;
  final String? aadhaarMasked;
  final String approvalStatus;
  final String? rejectionReason;
  final bool isCheckedIn;
  final String? checkedInAt;
  final String? photoUrl;

  PassAttendeeModel({
    required this.id,
    required this.name,
    required this.personType,
    required this.mobileNo,
    required this.whatsappNo,
    this.aadhaarMasked,
    required this.approvalStatus,
    this.rejectionReason,
    required this.isCheckedIn,
    this.checkedInAt,
    this.photoUrl,
  });

  factory PassAttendeeModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return PassAttendeeModel(
      id: parseInt(json['id']),
      name: json['name']?.toString() ?? '',
      personType: json['person_type']?.toString() ?? json['type']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? json['mobile']?.toString() ?? '',
      whatsappNo: json['whatsapp_no']?.toString() ?? json['whatsapp']?.toString() ?? '',
      aadhaarMasked: json['aadhaar_masked']?.toString() ?? json['aadhaar']?.toString(),
      approvalStatus: json['approval_status']?.toString() ?? json['status']?.toString() ?? '',
      rejectionReason: json['rejection_reason']?.toString(),
      isCheckedIn: json['is_checked_in'] == true || json['is_checked_in'] == 1 || json['checkin_status']?.toString().toLowerCase() == 'checked_in',
      checkedInAt: json['checked_in_at']?.toString(),
      photoUrl: json['photo_url']?.toString(),
    );
  }
}

class UpdatePassStatusRequestModel {
  final int? passId;
  final List<int>? passIds;
  final String action; // "approve" or "reject"
  final String? remarks;

  UpdatePassStatusRequestModel({
    this.passId,
    this.passIds,
    required this.action,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      if (passId != null) 'pass_id': passId,
      if (passIds != null && passIds!.isNotEmpty) 'pass_ids': passIds,
      'action': action,
      if (remarks != null && remarks!.isNotEmpty) 'remarks': remarks,
    };
  }
}

class UpdatePassStatusResponseModel {
  final bool success;
  final String message;
  final String action;
  final String newStatus;
  final int updatedCount;
  final List<int> updatedIds;

  UpdatePassStatusResponseModel({
    required this.success,
    this.message = '',
    this.action = '',
    this.newStatus = '',
    this.updatedCount = 0,
    required this.updatedIds,
  });

  factory UpdatePassStatusResponseModel.fromJson(Map<String, dynamic> json) {
    List<int> ids = [];
    if (json['updated_ids'] != null && json['updated_ids'] is List) {
      ids = (json['updated_ids'] as List)
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList();
    }

    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }

    return UpdatePassStatusResponseModel(
      success: json['success'] == true || json['success'] == 1,
      message: json['message']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      newStatus: json['new_status']?.toString() ?? '',
      updatedCount: parseInt(json['updated_count']),
      updatedIds: ids,
    );
  }
}
