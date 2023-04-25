import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MeetingNotifier extends StateNotifier<String>
    with DyteMeetingRoomEventsListener {
  MeetingNotifier(super.state);

  @override
  void onMeetingInitStarted() {
    super.onMeetingInitStarted();
    debugPrint("Meeting init.....");
    state = "init";
  }

  @override
  void onMeetingInitCompleted() {
    super.onMeetingInitCompleted();
    debugPrint("Meeting init Completed");
    state = "completed";
  }

  @override
  void onMeetingInitFailed(Exception exception) {
    super.onMeetingInitFailed(exception);
    debugPrint("Meeting init Failed");
    state = "failed";
  }
}

