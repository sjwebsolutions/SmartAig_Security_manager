class ActiveEventResponseModel {
  final bool success;
  final String message;
  final List<ActiveEventModel> data;

  ActiveEventResponseModel({
    required this.success,
    this.message = '',
    required this.data,
  });

  factory ActiveEventResponseModel.fromJson(Map<String, dynamic> json) {
    List<ActiveEventModel> eventList = [];
    if (json['data'] != null && json['data'] is List) {
      eventList = (json['data'] as List)
          .map((item) => ActiveEventModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ActiveEventResponseModel(
      success: json['success'] == true || json['success'] == 1,
      message: json['message']?.toString() ?? '',
      data: eventList,
    );
  }
}

class ActiveEventModel {
  final int id;
  final String eventCode;
  final String title;
  final String? subTitle;
  final String venue;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String? registrationDeadline;
  final int maxGuestsPerStudent;
  final bool requiresApproval;
  final bool requireAadhaar;
  final bool requirePhoto;
  final bool allowMultipleCheckins;
  final String bannerUrl;
  final LiveTelecastModel? liveTelecast;

  ActiveEventModel({
    required this.id,
    required this.eventCode,
    required this.title,
    this.subTitle,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    this.registrationDeadline,
    required this.maxGuestsPerStudent,
    required this.requiresApproval,
    required this.requireAadhaar,
    required this.requirePhoto,
    required this.allowMultipleCheckins,
    required this.bannerUrl,
    this.liveTelecast,
  });

  factory ActiveEventModel.fromJson(Map<String, dynamic> json) {
    return ActiveEventModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      eventCode: json['event_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subTitle: json['sub_title']?.toString(),
      venue: json['venue']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      registrationDeadline: json['registration_deadline']?.toString(),
      maxGuestsPerStudent: json['max_guests_per_student'] is int
          ? json['max_guests_per_student']
          : int.tryParse(json['max_guests_per_student']?.toString() ?? '0') ?? 0,
      requiresApproval: json['requires_approval'] == true || json['requires_approval'] == 1,
      requireAadhaar: json['require_aadhaar'] == true || json['require_aadhaar'] == 1,
      requirePhoto: json['require_photo'] == true || json['require_photo'] == 1,
      allowMultipleCheckins: json['allow_multiple_checkins'] == true || json['allow_multiple_checkins'] == 1,
      bannerUrl: json['banner_url']?.toString() ?? '',
      liveTelecast: json['live_telecast'] != null && json['live_telecast'] is Map<String, dynamic>
          ? LiveTelecastModel.fromJson(json['live_telecast'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LiveTelecastModel {
  final bool isLive;
  final String? youtubeUrl;
  final String? youtubeVideoId;
  final String? embedUrl;
  final String? title;
  final String? startedAt;
  final String? endedAt;

  LiveTelecastModel({
    required this.isLive,
    this.youtubeUrl,
    this.youtubeVideoId,
    this.embedUrl,
    this.title,
    this.startedAt,
    this.endedAt,
  });

  factory LiveTelecastModel.fromJson(Map<String, dynamic> json) {
    return LiveTelecastModel(
      isLive: json['is_live'] == true || json['is_live'] == 1,
      youtubeUrl: json['youtube_url']?.toString(),
      youtubeVideoId: json['youtube_video_id']?.toString(),
      embedUrl: json['embed_url']?.toString(),
      title: json['title']?.toString(),
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
    );
  }
}
