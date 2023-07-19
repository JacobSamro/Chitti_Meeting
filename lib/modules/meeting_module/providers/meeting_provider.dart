import 'package:chitti_meeting/modules/meeting_module/models/host_model.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:video_player/video_player.dart';

import '../../../services/locator.dart';
import '../states/meeting_states.dart';

class MeetingStateNotifier extends StateNotifier<MeetingStates> {
  MeetingStateNotifier({this.ref}) : super(RouterInitial());
  final Ref? ref;
  late final EventsListener<RoomEvent> _listener;
  EventsListener<RoomEvent> get listener => _listener;
  final Room room = locator<Room>();

  void changeState(MeetingStates state) {
    this.state = state;
  }

  onTrackPublished() {}

  void createListener() {
    _listener = locator<Room>().createListener();
  }

  void listen(BuildContext context) {
    _listener.on<ParticipantConnectedEvent>((event) {
      ref!
          .read(participantProvider.notifier)
          .addRemoteParticipantTrack(event.participant);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${event.participant.identity} connected')));
    });

    _listener.on<ParticipantDisconnectedEvent>((event) {
      ref!
          .read(participantProvider.notifier)
          .removeRemoteParticipantTrack(event.participant);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${event.participant.identity} disconnected')));
    });

    _listener.on<TrackSubscribedEvent>((event) {});

    _listener.on<TrackUnsubscribedEvent>((event) {});

    _listener.on<RoomDisconnectedEvent>((event) async {
      await locator<VideoPlayerController>().dispose();
      await locator.unregister<VideoPlayerController>();
      state = MeetingRoomDisconnected();
    });

    _listener.on<RoomReconnectingEvent>((event) async {
      state = MeetingRoomReconnecting();
      ref?.invalidate(participantProvider);
      await locator<VideoPlayerController>().dispose();
      await locator.unregister<VideoPlayerController>();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reconnecting to room')));
    });
    _listener.on<RoomReconnectedEvent>((event) {
      state = MeetingRoomJoinCompleted();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reconnected to room')));
    });
    _listener.on<TrackPublishedEvent>((event) {
      state = MeetingRoomJoinCompleted();
    });
  }

  void listenTrack(VoidCallback callback) {
    _listener.on<TrackUnpublishedEvent>((event) {
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
  ParticipantNotifier(super.state);

  final Room room = locator<Room>();

  Future<void> addLocalParticipantTrack() async {
    List<dynamic> participants = [];
    final HostModel host = await locator<MeetingRepositories>().getHostVideo();
    participants = [
      host,
      // {"name": "sakthi", "message": "hello"}
      room.localParticipant as Participant,
    ];
    for (var element in room.participants.values) {
      participants.add(element);
    }
    state = [...state, ...participants];
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
}

final StateNotifierProvider<ParticipantNotifier, List<dynamic>>
    participantProvider =
    StateNotifierProvider<ParticipantNotifier, List<dynamic>>(
        (ref) => ParticipantNotifier([]));
