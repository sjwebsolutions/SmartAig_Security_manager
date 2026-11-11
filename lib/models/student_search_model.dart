class StudentSearchResponseModel {
  final bool success;
  final String message;
  final List<StudentSearchModel> data;
  final int totalCount;

  StudentSearchResponseModel({
    required this.success,
    this.message = '',
    required this.data,
    this.totalCount = 0,
  });

  factory StudentSearchResponseModel.fromJson(Map<String, dynamic> json) {
    List<StudentSearchModel> studentList = [];
    if (json['data'] != null && json['data'] is List) {
      studentList = (json['data'] as List)
          .map((item) => StudentSearchModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return StudentSearchResponseModel(
      success: json['success'] == true || json['success'] == 1,
      message: json['message']?.toString() ?? '',
      data: studentList,
      totalCount: json['total_count'] is int
          ? json['total_count']
          : int.tryParse(json['total_count']?.toString() ?? '0') ?? 0,
    );
  }
}

class StudentSearchModel {
  final int id;
  final String studentName;
  final String admissionNumber;
  final String rollNo;
  final String studentUniqueId;
  final String className;
  final String sectionName;
  final String? streamName;
  final String fatherName;
  final String fatherMobile;
  final String motherName;
  final String motherMobile;
  final String whatsappNo;
  final String? studentAadhaar;
  final String? fatherAadhaar;
  final String? motherAadhaar;
  final String? studentPhotoUrl;
  final String? studentPhotoPath;
  final String? fatherPhotoUrl;
  final String? fatherPhotoPath;
  final String? motherPhotoUrl;
  final String? motherPhotoPath;
  final bool passExists;
  final int? passId;
  final String? passNumber;
  final String? approvalStatus;
  final String? checkinStatus;

  StudentSearchModel({
    required this.id,
    required this.studentName,
    required this.admissionNumber,
    required this.rollNo,
    required this.studentUniqueId,
    required this.className,
    required this.sectionName,
    this.streamName,
    required this.fatherName,
    required this.fatherMobile,
    required this.motherName,
    required this.motherMobile,
    required this.whatsappNo,
    this.studentAadhaar,
    this.fatherAadhaar,
    this.motherAadhaar,
    this.studentPhotoUrl,
    this.studentPhotoPath,
    this.fatherPhotoUrl,
    this.fatherPhotoPath,
    this.motherPhotoUrl,
    this.motherPhotoPath,
    required this.passExists,
    this.passId,
    this.passNumber,
    this.approvalStatus,
    this.checkinStatus,
  });

  factory StudentSearchModel.fromJson(Map<String, dynamic> json) {
    return StudentSearchModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      studentName: json['student_name']?.toString() ?? '',
      admissionNumber: json['admission_number']?.toString() ?? '',
      rollNo: json['roll_no']?.toString() ?? '',
      studentUniqueId: json['student_unique_id']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      sectionName: json['section_name']?.toString() ?? '',
      streamName: json['stream_name']?.toString(),
      fatherName: json['father_name']?.toString() ?? '',
      fatherMobile: json['father_mobile']?.toString() ?? '',
      motherName: json['mother_name']?.toString() ?? '',
      motherMobile: json['mother_mobile']?.toString() ?? '',
      whatsappNo: json['whatsapp_no']?.toString() ?? '',
      studentAadhaar: json['student_aadhaar']?.toString(),
      fatherAadhaar: json['father_aadhaar']?.toString(),
      motherAadhaar: json['mother_aadhaar']?.toString(),
      studentPhotoUrl: json['student_photo_url']?.toString(),
      studentPhotoPath: json['student_photo_path']?.toString(),
      fatherPhotoUrl: json['father_photo_url']?.toString(),
      fatherPhotoPath: json['father_photo_path']?.toString(),
      motherPhotoUrl: json['mother_photo_url']?.toString(),
      motherPhotoPath: json['mother_photo_path']?.toString(),
      passExists: json['pass_exists'] == true || json['pass_exists'] == 1,
      passId: json['pass_id'] is int ? json['pass_id'] : int.tryParse(json['pass_id']?.toString() ?? ''),
      passNumber: json['pass_number']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      checkinStatus: json['checkin_status']?.toString(),
    );
  }
}
