import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../common/constants/constants.dart';
import '../models/workshop_model.dart';
import '../states/meeting_states.dart';

class MeetingRepositories {
  const MeetingRepositories({required this.dio});
  final Dio dio;

  Future<String> getDateTime() async {
    final Response<dynamic> response = await dio.get(ApiConstants.dateTimeUrl);
    return response.data['dateTime'];
  }

  Future<void> addParticipant(String participantName, Room room1,
      String meetingId, bool isVideo, WidgetRef ref) async {
    final Room room = locator<Room>();
    // final int id = Random().nextInt(100);
    final Response response = await dio.post(ApiConstants.addParticipantUrl,
        data: {
          "roomId": meetingId,
          "participantName": participantName,
          "isVideo": isVideo
        });
    await room.connect(ApiConstants.livekitUrl, response.data['token'],
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultVideoPublishOptions: VideoPublishOptions(
            simulcast: true,
          ),
        ),
        fastConnectOptions: FastConnectOptions(
          microphone: const TrackOption(enabled: false),
          camera: TrackOption(enabled: isVideo),
        ));

    try {
      await room.localParticipant?.setCameraEnabled(isVideo);
      await room.localParticipant?.setMicrophoneEnabled(false);
      ref
          .read(meetingStateProvider.notifier)
          .changeState(MeetingRoomJoinCompleted());
    } catch (error) {
      throw Exception(error);
    }
  }

  List<dynamic> sortParticipant(ViewType view, WidgetRef ref) {
    if (view == ViewType.standard) return standardViewSort(ref);
    if (view == ViewType.gallery) return galleryViewSort(ref);
    return [...ref.read(participantProvider)];
  }

  List<List<dynamic>> standardViewSort(WidgetRef ref) {
    final List<dynamic> participants = ref.read(participantProvider);
    final List<List<dynamic>> sortValue = [
      for (var i = 0; i < participants.length; i += 2)
        participants.sublist(
            i, i + 2 <= participants.length ? i + 2 : participants.length)
    ];
    return sortValue;
  }

  List<List<dynamic>> galleryViewSort(WidgetRef ref) {
    final List<dynamic> participants = ref.read(participantProvider);
    final List<List<dynamic>> sortValue = [
      for (var i = 0; i < participants.length; i += 6)
        participants.sublist(
            i, i + 6 <= participants.length ? i + 6 : participants.length)
    ];
    return sortValue;
  }

  Future<Workshop> getWorkshop(String id) async {
    final Response<dynamic> response = await dio.post(ApiConstants.workshopUrl,
        data: {"hashId": id}).catchError((error) {
      throw Exception(error);
    });
    return Workshop.fromJson(response.data['workshop']);
  }
}
