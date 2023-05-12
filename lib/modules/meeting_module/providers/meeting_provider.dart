import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/meeting_states.dart';

class MeetingStateNotifier extends StateNotifier<MeetingStates>
    with DyteMeetingRoomEventsListener, DyteSelfEventsListener {
  MeetingStateNotifier() : super(RouterInitial());

  @override
  void onMeetingInitStarted() {
    state = MeetingInitStarted();
  }

  @override
  void onMeetingInitCompleted() {
    state = MeetingInitCompleted();
    debugPrint(state.toString());
  }

  @override
  void onMeetingInitFailed(Exception exception) {
    state = MeetingInitFailed(exception);
  }

  @override
  void onMeetingRoomJoinStarted() {
    state = MeetingRoomJoinStarted();
  }

  @override
  void onMeetingRoomJoinCompleted() {
    state = MeetingRoomJoinCompleted();
  }

  @override
  void onMeetingRoomJoinFailed(Exception exception) {
    state = MeetingRoomJoinFailed(exception);
  }

  @override
  void onMeetingRoomLeaveStarted() {
    state = MeetingRoomLeaveStarted();
  }

  @override
  void onMeetingRoomLeaveCompleted() {
    state = MeetingRoomLeaveCompleted();
  }

  @override
  void onMeetingRoomDisconnected() {
    state = MeetingRoomDisconnected();
  }

  @override
  void onWaitListStatusUpdate(DyteWaitListStatus waitListStatus) {
    state = SelfWaitingRoomStatusUpdate(waitListStatus);
  }
}

final meetingStateProvider =
    StateNotifierProvider<MeetingStateNotifier, MeetingStates>(
  (ref) => MeetingStateNotifier(),
);

//participant_state_notifier

class ParticipantStateNotifier extends StateNotifier<String>
    with DyteParticipantEventsListener {
  ParticipantStateNotifier({required this.context}) : super("");

  final BuildContext context;

  void videoUpdate(bool videoEnabled) {
    // state = VideoUpdated(participantId, isVideoOn);
  }
  @override
  void onParticipantJoin(DyteMeetingParticipant participant) {
    super.onParticipantJoin(participant);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${participant.name} joined the meeting"),
      ),
    );
  }
  @override
  void onParticipantLeave(DyteMeetingParticipant participant) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${participant.name} left the meeting"),
      ),
    );
  }

  @override
  void onUpdate(DyteRoomParticipants participants) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   // SnackBar(
    //   //   content: Text("${participants.grid} joined the meeting"),
    //   // ),
    // );
    debugPrint("participants.grid ${participants.toMap()}");
    state = "";
  }
}

final participantStateProvider = StateNotifierProvider.family<
    ParticipantStateNotifier, String, BuildContext>(
  (ref, context) => ParticipantStateNotifier(context: context),
);

class MeetingPageNotifier extends StateNotifier<int> {
  MeetingPageNotifier(super.state);

  void changePageIndex(int index) {
    state = index;
  }
}

final StateNotifierProvider<MeetingPageNotifier, int> meetingPageProvider =
    StateNotifierProvider<MeetingPageNotifier,int>((ref) => MeetingPageNotifier(0));
