class IssueWalkInPassRequestModel {
  final int eventId;
  final int studentId;
  final bool autoApprove;
  final bool autoCheckin;
  final String gateName;
  final String remarks;
  final List<WalkInAttendeeItem> attendees;

  IssueWalkInPassRequestModel({
    required this.eventId,
    required this.studentId,
    this.autoApprove = true,
    this.autoCheckin = true,
    this.gateName = 'main gate',
    this.remarks = 'Walk-in entry issued at gate',
    required this.attendees,
  });
}

class WalkInAttendeeItem {
  String personType; // student, father, mother, guardian, guest, other
  String name;
  String mobileNo;
  String whatsappNo;
  String aadhaarNumber;
  String? photoFilePath;
  String? existingPhotoPath;
  String? photoUrl;
  bool isAutoFilled;

  WalkInAttendeeItem({
    this.personType = 'father',
    this.name = '',
    this.mobileNo = '',
    this.whatsappNo = '',
    this.aadhaarNumber = '',
    this.photoFilePath,
    this.existingPhotoPath,
    this.photoUrl,
    this.isAutoFilled = false,
  });
}

class IssueWalkInPassResponseModel {
  final bool success;
  final String message;
  final int? passId;
  final String? passNumber;
  final String? status;

  IssueWalkInPassResponseModel({
    required this.success,
    this.message = '',
    this.passId,
    this.passNumber,
    this.status,
  });

  factory IssueWalkInPassResponseModel.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '');
    }

    return IssueWalkInPassResponseModel(
      success: json['success'] == true || json['success'] == 1,
      message: json['message']?.toString() ?? '',
      passId: parseInt(json['pass_id']),
      passNumber: json['pass_number']?.toString() ?? json['pass_no']?.toString(),
      status: json['status']?.toString(),
    );
  }
}
