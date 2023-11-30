import 'package:chitti_meet/modules/meeting_module/states/meeting_states.dart';

class MeetingSDKModel {
  final MeetingSDK meetingSDK;
  final bool isAudioMute;
  final bool isVideoMute;
  final bool isScreenShare;

  MeetingSDKModel(
      {required this.meetingSDK,
      required this.isAudioMute,
      required this.isVideoMute,
      required this.isScreenShare});
}
