
abstract class MeetingStates {}

class RouterInitial extends MeetingStates {}

class MeetingRoomJoinCompleted extends MeetingStates {}

class MeetingRoomDisconnected extends MeetingStates {}

class WaitingRoom extends MeetingStates {}

class MeetingRoomReconnecting extends MeetingStates {}

class MeetingRoomReconnected extends MeetingStates {}

class MeetingEnded extends MeetingStates {}

enum ViewType{standard,gallery,speaker,fullScreen}
