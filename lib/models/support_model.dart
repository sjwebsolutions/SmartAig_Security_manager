class SupportResponseModel {
  final bool success;
  final SupportData? data;

  SupportResponseModel({required this.success, this.data});

  factory SupportResponseModel.fromJson(Map<String, dynamic> json) {
    return SupportResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? SupportData.fromJson(json['data']) : null,
    );
  }
}

class SupportData {
  final String name;
  final String whatsapp;
  final String mobile;
  final String email;

  SupportData({
    required this.name,
    required this.whatsapp,
    required this.mobile,
    required this.email,
  });

  factory SupportData.fromJson(Map<String, dynamic> json) {
    return SupportData(
      name: json['name'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
    );
  }
}
