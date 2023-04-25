class ParticipantModel {
  final String? name;
  final String? picture;
  final String? presentName;
  final String? participantId;
  final String? meetingId;

  ParticipantModel(
      {this.name,
      this.picture,
      this.presentName,
      this.participantId,
      this.meetingId});
  Map<String, dynamic> toMap(ParticipantModel participant) {
    return {
      "name": participant.name,
      "picture": participant.picture,
      "preset_name": participant.presentName,
      "custom_participant_id": participant.participantId,
    };
  }
}
