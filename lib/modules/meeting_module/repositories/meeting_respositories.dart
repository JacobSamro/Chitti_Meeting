import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dyte_core/dyte_core.dart';

class MeetingRepositories {
  const MeetingRepositories({required this.client, required this.dio});
  final Dio dio;
  final DyteMobileClient client;

  Future<void> addParticipant() async {
    final int id = Random().nextInt(100);
    final Response response = await dio.post(
      "https://live-automation.cloud.chitti.xyz/api/workshops/participants",
      data: {
        "hashId": "c3778ac9-fae5-4f02-beec-1ddd63b6c2cb",
        "meetingId": "bbbbf5d3-f799-4be8-9eaf-fe54fa5a1e46",
        "name": "sakthi$id",
        "isVideo": false
      },
      // options: Options(headers: {
      //   "Authorization":
      //       "Basic ZWE0OGQ0MDItNTBlMS00ZWEyLWI5NjEtYmExZGU2OWNhYjhmOjM4NDQxYTM5NDEzN2ZhZjg2ODQx"
      // })
    );
    // return response.data['authToken'];
    client.init(DyteMeetingInfoV2(authToken: response.data['authToken']));
    // final DyteLocalUser localUser = client.localUser;
    // client.hostActions.disableParticipantAudio(DyteMeetingParticipant(
    //     id: localUser.id,
    //     userId: localUser.userId,
    //     name: localUser.name,
    //     isHost: localUser.isHost,
    //     flags: localUser.flags,
    //     audioEnabled: localUser.audioEnabled,
    //     videoEnabled: localUser.videoEnabled));
    // client.
  }
}
