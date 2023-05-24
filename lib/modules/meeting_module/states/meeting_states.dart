
import 'package:dyte_core/dyte_core.dart';

abstract class MeetingStates {}

class RouterInitial extends MeetingStates {}

class MeetingInitStarted extends MeetingStates {}

class MeetingInitCompleted extends MeetingStates {}

class MeetingInitFailed extends MeetingStates {
  final Exception error;
  MeetingInitFailed(this.error);
}

class MeetingRoomJoinStarted extends MeetingStates {}

class MeetingRoomJoinCompleted extends MeetingStates {}

class MeetingRoomJoinFailed extends MeetingStates {
  final Exception error;
  MeetingRoomJoinFailed(this.error);
}

class MeetingRoomLeaveStarted extends MeetingStates {}

class MeetingRoomLeaveCompleted extends MeetingStates {}

class MeetingRoomDisconnected extends MeetingStates {}

class SelfWaitingRoomStatusUpdate extends MeetingStates {
  final DyteWaitListStatus waitListStatus;
  SelfWaitingRoomStatusUpdate(this.waitListStatus);
}
