import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../common/constants/constants.dart';
import '../states/meeting_states.dart';

class MeetingRepositories {
  const MeetingRepositories({required this.dio});
  final Dio dio;

  Future<String> getDateTime() async {
    final Response<dynamic> response = await dio.get(ApiConstants.dateTimeUrl);
    return response.data['dateTime'];
  }

  Future<bool> addParticipant(String participantName, String passcode,
      String meetingId, bool isVideo, WidgetRef ref) async {
    final Response response =
        await dio.post(ApiConstants.addParticipantUrl, data: {
      "roomId": meetingId,
      "participantName": participantName,
      "passcode": passcode,
      "isVideo": isVideo
    });
    ref.read(workshopDetailsProvider.notifier).setHost(response.data['isHost']);
    return await connectMeeting(isVideo, ref, response.data['token']);
  }

  Future<bool> connectMeeting(bool isVideo, WidgetRef ref, String token) async {
    final Room room = locator<Room>();
    try {
      await room.connect(ApiConstants.livekitUrl, token,
          roomOptions: const RoomOptions(
            adaptiveStream: true,
            dynacast: true,
            defaultVideoPublishOptions: VideoPublishOptions(
              simulcast: false,
            ),
          ),
          fastConnectOptions: FastConnectOptions(
            microphone: const TrackOption(enabled: false),
            camera: TrackOption(enabled: isVideo),
          ));

      await room.localParticipant?.setCameraEnabled(isVideo);
      await room.localParticipant?.setMicrophoneEnabled(false);
      ref
          .read(meetingStateProvider.notifier)
          .changeState(MeetingRoomJoinCompleted());
      return true;
    } catch (error) {
      debugPrint(error.toString());
      return false;
      // throw Exception(error);
    }
  }

  List<dynamic> sortParticipant(ViewType view, WidgetRef ref) {
    if (view == ViewType.standard) return standardViewSort(ref);
    if (view == ViewType.gallery) return galleryViewSort(ref);
    final List<dynamic> participantList = ref.read(participantProvider);
    final List<Participant> screenShare = [];
    final List<dynamic> otherParticipants = [];
    for (var e in participantList) {
      e is Participant && e.isScreenShareEnabled()
          ? screenShare.add(e)
          : otherParticipants.add(e);
    }
    final List<dynamic> participants = [...screenShare, ...otherParticipants];
    return participants;
  }

  List<List<dynamic>> standardViewSort(WidgetRef ref) {
    final List<dynamic> participantList = ref.read(participantProvider);
    final List<Participant> screenShare = [];
    final List<dynamic> otherParticipants = [];
    for (var e in participantList) {
      e is Participant && e.isScreenShareEnabled()
          ? screenShare.add(e)
          : otherParticipants.add(e);
    }
    final List<dynamic> participants = [...screenShare, ...otherParticipants];
    final List<List<dynamic>> sortValue = [
      for (var i = 0; i < participants.length; i += 2)
        participants.sublist(
            i, i + 2 <= participants.length ? i + 2 : participants.length)
    ];
    return sortValue;
  }

  List<List<dynamic>> galleryViewSort(WidgetRef ref) {
    final List<dynamic> participantList = ref.read(participantProvider);
    final List<Participant> screenShare = [];
    final List<dynamic> otherParticipants = [];
    for (var e in participantList) {
      e is Participant && e.isScreenShareEnabled()
          ? screenShare.add(e)
          : otherParticipants.add(e);
    }
    final List<dynamic> participants = [...screenShare, ...otherParticipants];
    final List<List<dynamic>> sortValue = [
      for (var i = 0; i < participants.length; i += 6)
        participants.sublist(
            i, i + 6 <= participants.length ? i + 6 : participants.length)
    ];
    return sortValue;
  }

  Future<Map<String, dynamic>> getWorkshop(String id) async {
    final Response<dynamic> response = await dio.post(ApiConstants.workshopUrl,
        data: {"hashId": id}).catchError((error) {
      throw Exception(error);
    });
    return response.data;
  }
}
