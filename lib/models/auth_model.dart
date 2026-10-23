class OtpRequestModel {
  final String whatsappNumber;
  final String deviceUuid;
  final String deviceName;
  final String deviceOs;

  OtpRequestModel({
    required this.whatsappNumber,
    required this.deviceUuid,
    required this.deviceName,
    required this.deviceOs,
  });

  Map<String, dynamic> toJson() {
    return {
      'whatsapp_number': whatsappNumber,
      'device_uuid': deviceUuid,
      'device_name': deviceName,
      'device_os': deviceOs,
    };
  }
}

class OtpResponseModel {
  final bool success;
  final String message;

  OtpResponseModel({
    required this.success,
    required this.message,
  });

  factory OtpResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class OtpVerifyRequestModel {
  final String whatsappNumber;
  final String otpCode;
  final String deviceUuid;
  final String deviceName;
  final String deviceOs;

  OtpVerifyRequestModel({
    required this.whatsappNumber,
    required this.otpCode,
    required this.deviceUuid,
    required this.deviceName,
    required this.deviceOs,
  });

  Map<String, dynamic> toJson() {
    return {
      'whatsapp_number': whatsappNumber,
      'otp_code': otpCode,
      'device_uuid': deviceUuid,
      'device_name': deviceName,
      'device_os': deviceOs,
    };
  }
}

class GatekeeperInfo {
  final int id;
  final String name;
  final String staffType;
  final String? designation;
  final String whatsappNumber;
  final String phone;
  final String? email;
  final int schoolId;
  final String teacherUniqueId;
  final String gender;
  final String status;
  final String image;
  final String thumbnail;
  final String? address;

  GatekeeperInfo({
    required this.id,
    required this.name,
    required this.staffType,
    this.designation,
    required this.whatsappNumber,
    required this.phone,
    this.email,
    required this.schoolId,
    required this.teacherUniqueId,
    required this.gender,
    required this.status,
    required this.image,
    required this.thumbnail,
    this.address,
  });

  factory GatekeeperInfo.fromJson(Map<String, dynamic> json) {
    return GatekeeperInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      staffType: json['staff_type']?.toString() ?? '',
      designation: json['designation']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      schoolId: json['school_id'] is int ? json['school_id'] : int.tryParse(json['school_id']?.toString() ?? '0') ?? 0,
      teacherUniqueId: json['teacher_unique_id']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      address: json['address']?.toString(),
    );
  }
}

class AuthData {
  final String token;
  final String activeSession;
  final GatekeeperInfo? gatekeeper;

  AuthData({
    required this.token,
    required this.activeSession,
    this.gatekeeper,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] ?? '',
      activeSession: json['active_session'] ?? '',
      gatekeeper: json['gatekeeper'] != null
          ? GatekeeperInfo.fromJson(json['gatekeeper'])
          : null,
    );
  }
}

class OtpVerifyResponseModel {
  final bool success;
  final String message;
  final AuthData? data;

  OtpVerifyResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OtpVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
    );
  }
}

