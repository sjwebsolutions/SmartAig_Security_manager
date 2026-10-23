class Visitor {
  final int id;
  final String name;
  final String mobileNo;
  final String whatsappNo;
  final String visitorType;
  final String purposeOfVisit;
  final String visitDate;
  final String visitTime;
  final String markedVia;
  final String visitTypeDetail;
  final bool isLocationVerified;
  final String? createdBy;
  final List<dynamic> associatedStudents;

  Visitor({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.whatsappNo,
    required this.visitorType,
    required this.purposeOfVisit,
    required this.visitDate,
    required this.visitTime,
    required this.markedVia,
    required this.visitTypeDetail,
    required this.isLocationVerified,
    this.createdBy,
    required this.associatedStudents,
  });

  factory Visitor.fromJson(Map<String, dynamic> json) {
    return Visitor(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      mobileNo: json['mobile_no']?.toString() ?? '',
      whatsappNo: json['whatsapp_no']?.toString() ?? '',
      visitorType: json['visitor_type']?.toString() ?? '',
      purposeOfVisit: json['purpose_of_visit']?.toString() ?? '',
      visitDate: json['visit_date']?.toString() ?? '',
      visitTime: json['visit_time']?.toString() ?? '',
      markedVia: json['marked_via']?.toString() ?? '',
      visitTypeDetail: json['visit_type_detail']?.toString() ?? '',
      isLocationVerified: json['is_location_verified'] is bool
          ? json['is_location_verified']
          : (json['is_location_verified'] == 1 || json['is_location_verified'] == '1'),
      createdBy: json['created_by']?.toString(),
      associatedStudents: json['associated_students'] is List
          ? List<dynamic>.from(json['associated_students'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile_no': mobileNo,
      'whatsapp_no': whatsappNo,
      'visitor_type': visitorType,
      'purpose_of_visit': purposeOfVisit,
      'visit_date': visitDate,
      'visit_time': visitTime,
      'marked_via': markedVia,
      'visit_type_detail': visitTypeDetail,
      'is_location_verified': isLocationVerified,
      'created_by': createdBy,
      'associated_students': associatedStudents,
    };
  }
}

class CreateVisitorRequestModel {
  final String name;
  final String mobileNo;
  final String whatsappNo;
  final String visitorType;
  final String purposeOfVisit;
  final String visitType;
  final double? latitude;
  final double? longitude;

  CreateVisitorRequestModel({
    required this.name,
    required this.mobileNo,
    required this.whatsappNo,
    required this.visitorType,
    required this.purposeOfVisit,
    required this.visitType,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'mobile_no': mobileNo,
      'whatsapp_no': whatsappNo,
      'visitor_type': visitorType,
      'purpose_of_visit': purposeOfVisit,
      'visit_type': visitType,
    };

    if (latitude != null) {
      data['latitude'] = latitude;
    }
    if (longitude != null) {
      data['longitude'] = longitude;
    }

    return data;
  }
}

class CreateVisitorResponseModel {
  final bool success;
  final String message;
  final Visitor? data;

  CreateVisitorResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateVisitorResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateVisitorResponseModel(
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? Visitor.fromJson(json['data'])
          : null,
    );
  }
}

class VisitorResponseModel {
  final bool success;
  final List<Visitor> data;
  final String? message;

  VisitorResponseModel({
    required this.success,
    required this.data,
    this.message,
  });

  factory VisitorResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<Visitor> visitorList = list.map((i) => Visitor.fromJson(i)).toList();

    return VisitorResponseModel(
      success: json['success'] ?? false,
      data: visitorList,
      message: json['message']?.toString(),
    );
  }
}
