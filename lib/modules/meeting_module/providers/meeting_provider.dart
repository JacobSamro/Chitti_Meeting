import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_js/video_js.dart';
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
      // (locator<GlobalKey>().currentState as dynamic).remove();
      if (!kIsWeb) {
        await locator<Player>().dispose();
        await locator.unregister<VideoController>();
        await locator.unregister<Player>();
      } else {
        // await locator<VideoJsController>().dispose();
        await locator.unregister<VideoJsController>();
        await locator.unregister<GlobalKey>();
      }
      ref!.invalidate(workshopDetailsProvider);
      ref!.invalidate(viewProvider);
      ref!.read(chatProvider.notifier).reset();
      // ref!.refresh(chatProvider);
      ref!.invalidate(unReadMessageProvider);
      ref!.read(meetingStateProvider.notifier).removeListener();
      await locator<Room>().dispose();
      await locator.unregister<Room>();
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
        await locator.unregister<GlobalKey>();
        // ref!.invalidate(chatProvider);
        if (!kIsWeb) {
          await locator<Player>().dispose();
          await locator.unregister<VideoController>();
          await locator.unregister<Player>();
        } else {
          // await locator<VideoJsController>().dispose();
          await locator.unregister<VideoJsController>();
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    });

    _listener.on<RoomReconnectedEvent>((event) async {
      state = MeetingRoomJoinCompleted();
      context.showCustomSnackBar(
          content: 'Reconnected to room', iconPath: 'assets/icons/people.png');
      ref!
          .read(chatProvider.notifier)
          .listenMessage(ref!.read(workshopDetailsProvider.notifier).hashId);
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
  String _participantName = '';
  String get participantName => _participantName;

  Future<void> addLocalParticipantTrack() async {
    List<dynamic> participants = [];
    final Workshop workshop = ref.read(workshopDetailsProvider);

    if (workshop.sourceUrl!.isNotEmpty) {
      final HostModel host = HostModel(name: "Host", src: workshop.sourceUrl!);
      participants.add(host);
    }
    final MeetingSDK sdk = ref.read(meetingSDKProvider);

    if (sdk == MeetingSDK.livekit) {
      final Room room = locator<Room>();
      participants.add(room.localParticipant as Participant);
      for (var element in room.participants.values) {
        participants.add(element);
      }
    } else {
      final HMSSDK sdk = locator<HMSSDK>();
      final HMSLocalPeer? localPeer = await sdk.getLocalPeer();
      participants.add(localPeer);
      final List<HMSPeer>? remotePeers= await sdk.getRemotePeers();
      if (remotePeers != null && remotePeers.isNotEmpty) {
        participants = [...participants, ...remotePeers];
      }
    }
    state = [...participants];
  }

  void addRemoteParticipantTrack(dynamic participant) {
    state = [...state, participant];
  }

  void setParticipantName(String name) {
    _participantName = name;
  }

  void removeRemoteParticipantTrack(dynamic participant) {
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

class MeetingSDKNotifier extends StateNotifier<MeetingSDK>
    {
  MeetingSDKNotifier({required this.ref}):super(MeetingSDK.livekit);

  final Ref ref;
  
  bool _isLivekit = true;
  bool _isHMS = false;

  bool get isLivekit => _isLivekit;
  bool get isHMS => _isHMS;

  Future<bool> isAudioMuted({HMSPeer? peer}) async {
    if (state == MeetingSDK.livekit) {
      final Room room = locator<Room>();
      return room.localParticipant!.isMicrophoneEnabled();
    } else {
      final HMSSDK sdk = locator<HMSSDK>();
      final HMSPeer? localPeer = await sdk.getLocalPeer();
      return  peer==null?localPeer!.audioTrack==null:peer.audioTrack==null;
    }
  }

  Future<bool> isVideoMuted() async {
    if (state == MeetingSDK.livekit) {
      final Room room = locator<Room>();
      return room.localParticipant!.isCameraEnabled();
    } else {
      final HMSSDK sdk = locator<HMSSDK>();
      final HMSPeer? localPeer = await sdk.getLocalPeer();
      return  localPeer!.audioTrack==null;
    }
  }

  Future<void> enableAudio() async {
    if (state == MeetingSDK.livekit) {
      final Room room = locator<Room>();
        await room.localParticipant?.setMicrophoneEnabled(true);
    } else {
      final HMSSDK sdk = locator<HMSSDK>();
      await sdk.toggleMicMuteState();
    }
  }

  Future<void> disableAudio() async {
    if (state == MeetingSDK.livekit) {
      final Room room = locator<Room>();
        await room.localParticipant?.setMicrophoneEnabled(false);
    } else {
      final HMSSDK sdk = locator<HMSSDK>();
      await sdk.toggleMicMuteState();
    }
  }

  Future<void> enableVideo() async {
    if (state == MeetingSDK.livekit) {
      final Room room = locator<Room>();
        await room.localParticipant?.setMicrophoneEnabled(true);
    } else {
      final HMSSDK sdk = locator<HMSSDK>();
      final data=await sdk.toggleCameraMuteState();
      print(data.toString());
    }
  }

  Future<void> disableVideo() async {
    if (state == MeetingSDK.livekit) {
      final Room room = locator<Room>();
        await room.localParticipant?.setMicrophoneEnabled(false);
    } else {
      final HMSSDK sdk = locator<HMSSDK>();
      await sdk.toggleCameraMuteState();
    }
  }

  void addCallback(){
    
  }

  void changeSDK(MeetingSDK sdk) {
    if (sdk == MeetingSDK.hms) {
      _isLivekit = false;
      _isHMS = true;
    }
    state = sdk;
  }
}

final meetingSDKProvider =
    StateNotifierProvider<MeetingSDKNotifier, MeetingSDK>(
        (ref) => MeetingSDKNotifier(ref: ref));

class HMSMeetingListeners implements HMSUpdateListener {
  HMSMeetingListeners({ this.context,  this.ref});

  final WidgetRef? ref;
  final BuildContext? context;
  get listener => this;

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice? currentAudioDevice,
      List<HMSAudioDevice>? availableAudioDevice}) {}

  @override
  void onChangeTrackStateRequest(
      {required HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onHMSError({required HMSException error}) {}

  @override
  Future<void> onJoin({required HMSRoom room}) async {
       
    await ref!.read(participantProvider.notifier).addLocalParticipantTrack();
    ref!
        .read(meetingStateProvider.notifier)
        .changeState(MeetingRoomJoinCompleted());
  }

  @override
  void onMessage({required HMSMessage message}) {}

  @override
  void onPeerListUpdate(
      {required List<HMSPeer> addedPeers,
      required List<HMSPeer> removedPeers}) {}

  @override
  void onPeerUpdate({required HMSPeer peer, required HMSPeerUpdate update}) {
    switch (update) {
      case HMSPeerUpdate.peerJoined:
        ref!.read(participantProvider.notifier).addRemoteParticipantTrack(peer);
        context!.showCustomSnackBar(
            content: '${peer.name} connected',
            iconPath: 'assets/icons/user_rounded.png');
        break;
      case HMSPeerUpdate.peerLeft:
        ref!
            .read(participantProvider.notifier)
            .removeRemoteParticipantTrack(peer);
        context!.showCustomSnackBar(
            content: '${peer.name} disconnected',
            iconPath: 'assets/icons/user_rounded.png');
        break;
      case HMSPeerUpdate.roleUpdated:
        break;
      case HMSPeerUpdate.metadataChanged:
        break;
      case HMSPeerUpdate.nameChanged:
        break;
      case HMSPeerUpdate.defaultUpdate:
        break;
      case HMSPeerUpdate.networkQualityUpdated:
        break;
      default:
        debugPrint('$update $peer');
        break;
    }
  }

  @override
  void onReconnected() {}

  @override
  void onReconnecting() {}

  @override
  void onRemovedFromRoom(
      {required HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {}

  @override
  void onRoleChangeRequest({required HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({required HMSRoom room, required HMSRoomUpdate update}) {}

  @override
  void onSessionStoreAvailable({HMSSessionStore? hmsSessionStore}) {}

  @override
  void onTrackUpdate(
      {required HMSTrack track,
      required HMSTrackUpdate trackUpdate,
      required HMSPeer peer}) {

        switch (trackUpdate) {
          case HMSTrackUpdate.trackAdded:
            // TODO: Handle this case.
            break;
          case HMSTrackUpdate.trackRemoved:
            // TODO: Handle this case.
            break;
          case HMSTrackUpdate.trackMuted:
            // peer.videoTrack=null;
            break;
          case HMSTrackUpdate.trackUnMuted:
            break;
          case HMSTrackUpdate.trackDescriptionChanged:
            // TODO: Handle this case.
            break;
          case HMSTrackUpdate.trackDegraded:
            // TODO: Handle this case.
            break;
          case HMSTrackUpdate.trackRestored:
            // TODO: Handle this case.
            break;
          case HMSTrackUpdate.defaultUpdate:
            // TODO: Handle this case.
            break;
        } 
         

          debugPrint(peer.toString());
      }

  @override
  void onUpdateSpeakers({required List<HMSSpeaker> updateSpeakers}) {}
}
