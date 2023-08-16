import 'package:chitti_meeting/modules/chat_module/providers/chat_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/models/host_model.dart';
import 'package:chitti_meeting/modules/meeting_module/models/workshop_model.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
          content: '${event.participant.name} connected',
          iconPath: 'assets/icons/user_rounded.png');
    });

    _listener.on<ParticipantDisconnectedEvent>((event) {
      ref!
          .read(participantProvider.notifier)
          .removeRemoteParticipantTrack(event.participant);
      Utils.showCustomSnackBar(
          buildContext: context,
          content: '${event.participant.name} disconnected',
          iconPath: 'assets/icons/user_rounded.png');
    });

    _listener.on<RoomDisconnectedEvent>((event) async {
      ref!.read(participantProvider.notifier).reset();
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        await locator<Player>().dispose();
        await locator.unregister<VideoController>();
        await locator.unregister<Player>();
      } else {
        await locator<VideoPlayerController>().dispose();
        await locator.unregister<VideoPlayerController>();
      }
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
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
        await locator<Player>().dispose();
        await locator.unregister<VideoController>();
        await locator.unregister<Player>();
      } else {
        await locator<VideoPlayerController>().dispose();
        await locator.unregister<VideoPlayerController>();
      }
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
    _listener.on<ParticipantEvent>((event) {
      callback();
    });
    _listener.on<LocalTrackPublishedEvent>((event) {
      callback();
    });
    _listener.on<LocalTrackUnpublishedEvent>((event) {
      callback();
    });
    _listener.on<TrackPublishedEvent>((event) {
      state == MeetingRoomJoinCompleted() ? callback() : null;
    });

    _listener.on<TrackMutedEvent>((event) {
      callback();
    });
    _listener.on<SpeakingChangedEvent>((event) {
      callback();
    });
    _listener.on<ActiveSpeakersChangedEvent>((event) {
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
  String _participantName = '';
  List<dynamic> _participants = [];
  String get participantName => _participantName;
  List<dynamic> get participants => _participants;

  Future<void> addLocalParticipantTrack() async {
    List<dynamic> participants = [];
    final Workshop workshop = ref.read(workshopDetailsProvider);
    if (workshop.sourceUrl!.isNotEmpty) {
      final HostModel host = HostModel(name: "Host", src: workshop.sourceUrl!);
      participants.add(host);
    }
    participants.add(room.localParticipant as Participant);
    for (var element in room.participants.values) {
      participants.add(element);
    }
    state = [...participants];
    _participants = state;
  }

  void addRemoteParticipantTrack(Participant participant) {
    state = [...state, participant];
    _participants = state;
  }

  void setParticipantName(String name) {
    _participantName = name;
  }

  void removeRemoteParticipantTrack(Participant participant) {
    final List<dynamic> newState = state
        .where((element) =>
            element is HostModel ? true : element.sid != participant.sid)
        .toList();
    state = newState;
    _participants = state;
  }

  void reset() {
    state = [];
    _participants = state;
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
    final Map<String, dynamic> workshopDetails =
        await locator<MeetingRepositories>().getWorkshop(id);
    if (workshopDetails['success'] == false) {
      ref.read(meetingStateProvider.notifier).changeState(MeetingNotFound());
      return false;
    }
    state = Workshop.fromJson(workshopDetails['workshop']);

    if (state.meetingStatus == 'ended') {
      ref.read(meetingStateProvider.notifier).changeState(MeetingEnded());
      return false;
    }
    if (state.meetingStatus == 'notstarted') {
      ref.read(meetingStateProvider.notifier).changeState(WaitingRoom());
      return false;
    }
    return true;
  }

  void setHost(bool host) {
    final Workshop newState = state;
    newState.isHost = host;
    state = newState;
  }
}

final workshopDetailsProvider =
    StateNotifierProvider<WorkshopDetialsNotifier, Workshop>(
        (ref) => WorkshopDetialsNotifier(ref));
