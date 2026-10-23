class GatePass {
  final int id;
  final String gatePassNo;
  final String date;
  final String time;
  final String exitTime;
  final String reason;
  final String relation;
  final String personName;
  final String contactNo;
  final String status;
  final String createdBy;
  final String approvedBy;
  final String? approvedAt;
  final String type;
  final String className;
  final String sectionName;
  final String? streamName;

  GatePass({
    required this.id,
    required this.gatePassNo,
    required this.date,
    required this.time,
    required this.exitTime,
    required this.reason,
    required this.relation,
    required this.personName,
    required this.contactNo,
    required this.status,
    required this.createdBy,
    required this.approvedBy,
    this.approvedAt,
    required this.type,
    required this.className,
    required this.sectionName,
    this.streamName,
  });

  factory GatePass.fromJson(Map<String, dynamic> json) {
    return GatePass(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      gatePassNo: json['gate_pass_no']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      exitTime: json['exit_time']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      relation: json['relation']?.toString() ?? '',
      personName: json['person_name']?.toString() ?? '',
      contactNo: json['contact_no']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdBy: json['created_by']?.toString() ?? '',
      approvedBy: json['approved_by']?.toString() ?? '',
      approvedAt: json['approved_at']?.toString(),
      type: json['type']?.toString() ?? '',
      className: json['class_name']?.toString() ?? '',
      sectionName: json['section_name']?.toString() ?? '',
      streamName: json['stream_name']?.toString(),
    );
  }
}

class GatePassResponseModel {
  final bool success;
  final List<GatePass> data;

  GatePassResponseModel({
    required this.success,
    required this.data,
  });

  factory GatePassResponseModel.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List? ?? [];
    List<GatePass> gatePassList = list.map((i) => GatePass.fromJson(i)).toList();

    return GatePassResponseModel(
      success: json['success'] ?? false,
      data: gatePassList,
    );
  }
}
