import 'package:chitti_meeting/common/constants/constants.dart';
import 'package:dio/dio.dart';
import 'package:dyte_core/dyte_core.dart';
// import 'package:dyte_uikit/dyte_uikit.dart';
import 'package:flutter/material.dart';

class MeetingRepositories {
  final Dio dio;
  final DyteMobileClient client;
  const MeetingRepositories({required this.client, required this.dio});

  Future<DyteMobileClient> addParticipant(String name) async {
    try {
      Response<dynamic> response =
          await dio.post(ApiConstants.addParticipantUrl, data: {
        "hashId": "1246b769-a363-4f67-8b2f-9675a29315a0",
        "meetingId": "bbbfec0d-9b25-41ed-8c25-f8ec257c8018",
        "name": name,
        "isVideo": false
      });
      debugPrint(response.data.toString());
      final DyteMeetingInfo meetingInfo = DyteMeetingInfo(
          authToken: response.data['authToken'],
          roomName: 'bbbfec0d-9b25-41ed-8c25-f8ec257c8018');
      client.init(meetingInfo);
      // client.joinRoom();
      return client;
    } catch (e) {
      throw Exception(e);
    }
  }
}
