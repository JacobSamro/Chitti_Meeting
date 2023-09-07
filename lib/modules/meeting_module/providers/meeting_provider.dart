import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';
import '../../../services/locator.dart';
import '../../../utils/utils.dart';
import '../../chat_module/providers/chat_provider.dart';
import '../../view_module/providers/view_provider.dart';
import '../models/host_model.dart';
import '../models/workshop_model.dart';
import '../repositories/meeting_respositories.dart';
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
      context.showCustomSnackBar(
          content: '${event.participant.name} connected',
          iconPath: 'assets/icons/user_rounded.png');
    });

    _listener.on<ParticipantDisconnectedEvent>((event) {
      ref!
          .read(participantProvider.notifier)
          .removeRemoteParticipantTrack(event.participant);
      context.showCustomSnackBar(
          content: '${event.participant.name} disconnected',
          iconPath: 'assets/icons/user_rounded.png');
    });

    _listener.on<RoomDisconnectedEvent>((event) async {
      // ref!.read(participantProvider.notifier).reset();
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
      await locator<Room>().dispose();
      locator.unregister<Room>();
      locator.registerLazySingleton(() => Room());
      state = MeetingRoomDisconnected();
    });

    _listener.on<RoomReconnectingEvent>((event) async {
      try {
        ref!.read(participantProvider.notifier).reset();
        context.showCustomSnackBar(
            content: 'Reconnecting to room',
            iconPath: 'assets/icons/people.png');
        ref!.read(chatProvider.notifier).reset();
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
          await locator<Player>().dispose();
          await locator.unregister<VideoController>();
          await locator.unregister<Player>();
        } else {
          await locator<VideoPlayerController>().dispose();
          await locator.unregister<VideoPlayerController>();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    _listener.on<RoomReconnectedEvent>((event) async {
      state = MeetingRoomJoinCompleted();
      context.showCustomSnackBar(
          content: 'Reconnected to room', iconPath: 'assets/icons/people.png');
      await ref!.read(participantProvider.notifier).addLocalParticipantTrack();
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

  void sortOrder(VoidCallback callback) {
    _listener.on<TrackSubscribedEvent>((event) {
      callback();
    });
    _listener.on<TrackUnsubscribedEvent>((event) {
      callback();
    });
    _listener.on<LocalTrackPublishedEvent>((event) {
      callback();
    });
    _listener.on<LocalTrackUnpublishedEvent>((event) {
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
  String _meetingId = '';
  String get meetingId => _meetingId;

  void changePageIndex(int index) {
    state = index;
  }

  void setMeetingId(String id) {
    _meetingId = id;
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
  String get participantName => _participantName;

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
  }

  void addRemoteParticipantTrack(Participant participant) {
    state = [...state, participant];
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
