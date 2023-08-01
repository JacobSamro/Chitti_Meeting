import 'package:chitti_meeting/modules/chat_module/providers/chat_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/models/host_model.dart';
import 'package:chitti_meeting/modules/meeting_module/models/workshop_model.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:video_player/video_player.dart';

import '../../../services/locator.dart';
import '../../../utils/utils.dart';
import '../../view_module/providers/view_provider.dart';
import '../states/meeting_states.dart';

class MeetingStateNotifier extends StateNotifier<MeetingStates> {
  MeetingStateNotifier({this.ref}) : super(RouterInitial());
  final Ref? ref;
  late EventsListener<RoomEvent> _listener;
  EventsListener<RoomEvent> get listener => _listener;

  void changeState(MeetingStates state) {
    this.state = state;
  }

  void createListener() {
    _listener = locator<Room>().createListener();
  }

  void listen(BuildContext context) {
    _listener.on<ParticipantConnectedEvent>((event) {
      ref!
          .read(participantProvider.notifier)
          .addRemoteParticipantTrack(event.participant);
      Utils.showCustomSnackBar(
          buildContext: context,
          content: '${event.participant.identity} connected',
          iconPath: 'assets/icons/user_rounded.png');
    });

    _listener.on<ParticipantDisconnectedEvent>((event) {
      ref!
          .read(participantProvider.notifier)
          .removeRemoteParticipantTrack(event.participant);
      Utils.showCustomSnackBar(
          buildContext: context,
          content: '${event.participant.identity} disconnected',
          iconPath: 'assets/icons/user_rounded.png');
    });

    _listener.on<TrackSubscribedEvent>((event) {});

    _listener.on<TrackUnsubscribedEvent>((event) {});

    _listener.on<RoomDisconnectedEvent>((event) async {
      ref!.read(participantProvider.notifier).reset();
      await locator<VideoPlayerController>().dispose();
      await locator.unregister<VideoPlayerController>();
      ref!.invalidate(workshopDetailsProvider);
      ref!.invalidate(viewProvider);
      ref!.invalidate(chatProvider);
      ref!.invalidate(unReadMessageProvider);
      ref!.read(meetingStateProvider.notifier).removeListener();
      state = MeetingRoomDisconnected();
    });

    _listener.on<RoomReconnectingEvent>((event) async {
      state = MeetingRoomReconnecting();
      ref!.read(participantProvider.notifier).reset();
      Utils.showCustomSnackBar(
          buildContext: context,
          content: 'Reconnecting to room',
          iconPath: 'assets/icons/people.png');
      await locator<VideoPlayerController>().dispose();
      await locator.unregister<VideoPlayerController>();
    });
    _listener.on<RoomReconnectedEvent>((event) {
      state = MeetingRoomJoinCompleted();
      Utils.showCustomSnackBar(
          buildContext: context,
          content: 'Reconnected to room',
          iconPath: 'assets/icons/people.png');
    });
    _listener.on<TrackPublishedEvent>((event) {
      state = MeetingRoomJoinCompleted();
    });
  }

  void listenTrack(VoidCallback callback) {
    _listener.on<TrackUnpublishedEvent>((event) {
      callback();
    });
    _listener.on<LocalTrackPublishedEvent>((event) {
      callback();
    });
    _listener.on<TrackPublishedEvent>((event) {
      state == MeetingRoomJoinCompleted() ? callback() : null;
    });

    _listener.on<TrackMutedEvent>((event) {
      callback();
    });
    _listener.on<TrackUnmutedEvent>((event) {
      callback();
    });
  }

  void removeListener() {
    _listener.dispose();
  }
}

final meetingStateProvider =
    StateNotifierProvider<MeetingStateNotifier, MeetingStates>(
  (ref) => MeetingStateNotifier(ref: ref),
);

class MeetingPageNotifier extends StateNotifier<int> {
  MeetingPageNotifier(super.state);
  void changePageIndex(int index) {
    state = index;
  }
}

final StateNotifierProvider<MeetingPageNotifier, int> meetingPageProvider =
    StateNotifierProvider<MeetingPageNotifier, int>(
        (ref) => MeetingPageNotifier(0));

class ParticipantNotifier extends StateNotifier<List<dynamic>> {
  ParticipantNotifier(this.ref) : super([]);
  final Ref ref;
  final Room room = locator<Room>();

  Future<void> addLocalParticipantTrack() async {
    List<dynamic> participants = [];
    final Workshop workshop = ref.read(workshopDetailsProvider);
    final HostModel host = HostModel(name: "Host", src: workshop.sourceUrl!);
    participants = [
      host,
      room.localParticipant as Participant,
    ];
    for (var element in room.participants.values) {
      participants.add(element);
    }
    state = [...participants];
  }

  void addRemoteParticipantTrack(Participant participant) {
    state = [...state, participant];
  }

  void removeRemoteParticipantTrack(Participant participant) {
    final List<dynamic> newState = state
        .where((element) =>
            element is HostModel ? true : element.sid != participant.sid)
        .toList();
    state = newState;
  }

  void reset() {
    state = [];
  }
}

final StateNotifierProvider<ParticipantNotifier, List<dynamic>>
    participantProvider =
    StateNotifierProvider<ParticipantNotifier, List<dynamic>>(
        (ref) => ParticipantNotifier(ref));

class WorkshopDetialsNotifier extends StateNotifier<Workshop> {
  WorkshopDetialsNotifier(this.ref) : super(Workshop());
  final Ref ref;
  String hashId = '';
  Future<bool> getWorkshopDetials(String id) async {
    hashId = id;
    final Workshop workshop =
        await locator<MeetingRepositories>().getWorkshop(id);
    if (workshop.meetingStatus == 'ended') {
      ref.read(meetingStateProvider.notifier).changeState(MeetingEnded());
      return false;
    }
    if (workshop.meetingStatus == 'notstarted') {
      ref.read(meetingStateProvider.notifier).changeState(WaitingRoom());
      return false;
    }
    state = workshop;
    return true;
  }
}

final workshopDetailsProvider =
    StateNotifierProvider<WorkshopDetialsNotifier, Workshop>(
        (ref) => WorkshopDetialsNotifier(ref));
