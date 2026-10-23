class PolicyResponseModel {
  final bool success;
  final PolicyData? data;

  PolicyResponseModel({required this.success, this.data});

  factory PolicyResponseModel.fromJson(Map<String, dynamic> json) {
    return PolicyResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? PolicyData.fromJson(json['data']) : null,
    );
  }
}

class PolicyData {
  final String termsOfUse;
  final String privacyPolicy;

  PolicyData({
    required this.termsOfUse,
    required this.privacyPolicy,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      termsOfUse: json['terms_of_use'] ?? '',
      privacyPolicy: json['privacy_policy'] ?? '',
    );
  }
}
