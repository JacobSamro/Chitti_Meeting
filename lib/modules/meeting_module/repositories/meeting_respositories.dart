import 'package:dio/dio.dart';
import 'package:dyte_core/dyte_core.dart';

class MeetingRepositories {
  const MeetingRepositories({required this.client, required this.dio});
  final Dio dio;
  final DyteMobileClient client;

  Future<void> addParticipant(participantName, isVideo) async {
    final Response response = await dio.post(
      "https://live-automation.cloud.chitti.xyz/api/workshops/participants",
      data: {
        "hashId": "9d895280-eab9-404b-a77d-39338dcba2ba",
        "meetingId": "bbb33fbc-ae1a-49d7-9faf-4755239d076c",
        "name": participantName,
        "isVideo": isVideo,
      },
    );
    client.init(DyteMeetingInfoV2(authToken: response.data['authToken']));
  }
}
