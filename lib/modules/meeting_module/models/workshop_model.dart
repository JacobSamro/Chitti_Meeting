class Workshop {
  String? meetingId;
  String? scheduledAt;
  String? type;
  int? curriculumId;
  String? sourceUrl;
  String? meetingStatus;

  Workshop(
      {this.meetingId,
      this.scheduledAt,
      this.type,
      this.curriculumId,
      this.sourceUrl,
      this.meetingStatus});

  Workshop.fromJson(Map<String, dynamic> json) {
    meetingId = json['meetingId'];
    scheduledAt = json['scheduledAt'];
    type = json['type'];
    curriculumId = json['curriculumId'];
    sourceUrl = json['sourceUrl'];
    meetingStatus = json['meetingStatus'];
  }
}