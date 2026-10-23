import 'package:security_manager/models/auth_model.dart';

class SchoolInfo {
  final int id;
  final String schoolName;

  SchoolInfo({
    required this.id,
    required this.schoolName,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) {
    return SchoolInfo(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      schoolName: json['school_name']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}

class StatisticsInfo {
  final int totalToday;
  final int pendingToday;
  final int approvedToday;
  final int rejectedToday;

  StatisticsInfo({
    required this.totalToday,
    required this.pendingToday,
    required this.approvedToday,
    required this.rejectedToday,
  });

  factory StatisticsInfo.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is int) return val;
      if (val is double) return val.toInt();
      return int.tryParse(val?.toString() ?? '0') ?? 0;
    }
    return StatisticsInfo(
      totalToday: parseInt(json['total_today']),
      pendingToday: parseInt(json['pending_today']),
      approvedToday: parseInt(json['approved_today']),
      rejectedToday: parseInt(json['rejected_today']),
    );
  }
}

class DashboardData {
  final GatekeeperInfo? gatekeeper;
  final String activeSession;
  final SchoolInfo? school;
  final StatisticsInfo? statistics;
  final List<dynamic> todayGatePasses;
  final bool? isClockedIn;
  final String? clockInTime;
  final String? clockOutTime;
  final String? attendanceStatus;

  DashboardData({
    this.gatekeeper,
    required this.activeSession,
    this.school,
    this.statistics,
    required this.todayGatePasses,
    this.isClockedIn,
    this.clockInTime,
    this.clockOutTime,
    this.attendanceStatus,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    bool? clockedInStatus;
    String? clockIn;
    String? clockOut;
    String? statusStr;

    Map<String, dynamic>? att;
    if (json['attendance_today'] is Map<String, dynamic>) {
      att = json['attendance_today'] as Map<String, dynamic>;
    } else if (json['attendance'] is Map<String, dynamic>) {
      att = json['attendance'] as Map<String, dynamic>;
    } else if (json['attendance'] is List && (json['attendance'] as List).isNotEmpty && (json['attendance'] as List).first is Map<String, dynamic>) {
      att = (json['attendance'] as List).first as Map<String, dynamic>;
    } else if (json['today_attendance'] is Map<String, dynamic>) {
      att = json['today_attendance'] as Map<String, dynamic>;
    } else if (json['today_attendance'] is List && (json['today_attendance'] as List).isNotEmpty && (json['today_attendance'] as List).first is Map<String, dynamic>) {
      att = (json['today_attendance'] as List).first as Map<String, dynamic>;
    } else if (json['user_attendance'] is Map<String, dynamic>) {
      att = json['user_attendance'] as Map<String, dynamic>;
    } else if (json['user_attendance'] is List && (json['user_attendance'] as List).isNotEmpty && (json['user_attendance'] as List).first is Map<String, dynamic>) {
      att = (json['user_attendance'] as List).first as Map<String, dynamic>;
    } else if (json['gatekeeper'] is Map<String, dynamic> && (json['gatekeeper'] as Map<String, dynamic>)['attendance'] is Map<String, dynamic>) {
      att = (json['gatekeeper'] as Map<String, dynamic>)['attendance'] as Map<String, dynamic>;
    }

    if (att != null) {
      clockIn = att['clock_in']?.toString() ?? att['clock_in_time']?.toString() ?? att['in_time']?.toString();
      clockOut = att['clock_out']?.toString() ?? att['clock_out_time']?.toString() ?? att['out_time']?.toString();
      statusStr = att['status']?.toString() ?? att['label']?.toString() ?? att['attendance_status']?.toString();
    } else {
      clockIn = json['clock_in']?.toString() ?? json['clock_in_time']?.toString() ?? json['in_time']?.toString();
      clockOut = json['clock_out']?.toString() ?? json['clock_out_time']?.toString() ?? json['out_time']?.toString();
      statusStr = json['status']?.toString() ?? json['attendance_status']?.toString();
    }

    if (json.containsKey('is_clocked_in') && json['is_clocked_in'] != null) {
      final val = json['is_clocked_in'];
      clockedInStatus = val == true || val == 1 || val == '1' || val.toString().toLowerCase() == 'true';
    } else if (json.containsKey('clocked_in') && json['clocked_in'] != null) {
      final val = json['clocked_in'];
      clockedInStatus = val == true || val == 1 || val == '1' || val.toString().toLowerCase() == 'true';
    } else if (statusStr != null && statusStr.isNotEmpty) {
      final status = statusStr.toLowerCase();
      if (status == 'clock_out' || status == 'clocked_out') {
        clockedInStatus = false;
      } else if (status == 'clock_in' || status == 'clocked_in' || status == 'present') {
        clockedInStatus = true;
      }
    }

    if (clockedInStatus == null && clockIn != null && clockIn.isNotEmpty) {
      clockedInStatus = (clockOut == null || clockOut.isEmpty);
    }

    return DashboardData(
      gatekeeper: json['gatekeeper'] is Map<String, dynamic>
          ? GatekeeperInfo.fromJson(json['gatekeeper'])
          : null,
      activeSession: json['active_session']?.toString() ?? '',
      school: json['school'] is Map<String, dynamic>
          ? SchoolInfo.fromJson(json['school'])
          : null,
      statistics: json['statistics'] is Map<String, dynamic>
          ? StatisticsInfo.fromJson(json['statistics'])
          : null,
      todayGatePasses: json['today_gate_passes'] is List ? json['today_gate_passes'] : [],
      isClockedIn: clockedInStatus,
      clockInTime: clockIn,
      clockOutTime: clockOut,
      attendanceStatus: statusStr,
    );
  }
}

class DashboardResponseModel {
  final bool success;
  final DashboardData? data;

  DashboardResponseModel({
    required this.success,
    this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dataMap;
    if (json['data'] is Map<String, dynamic>) {
      dataMap = json['data'] as Map<String, dynamic>;
    } else {
      dataMap = json;
    }

    return DashboardResponseModel(
      success: json['success'] == true || json['success']?.toString() == 'true',
      data: DashboardData.fromJson(dataMap),
    );
  }
}
