import 'package:chitti_meeting/modules/meeting_module/presentation/main_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/meeting_ended_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/test_camera_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/constants/app_theme_data.dart';
import 'modules/meeting_module/states/meeting_states.dart';

void main() {
  setup();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Chitti Meeting',
        theme: appThemeData,
        home: const HomeScreen());
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final client = locator<DyteMobileClient>();
  final pages = <Widget>[
    const TestCamera(),
    Center(
      child: GestureDetector(
          onTap: () {}, child: const CircularProgressIndicator()),
    ),
    const MainScreen(),
    const MeetingEndedScreen()
  ];
  @override
  void initState() {
    super.initState();
    ref.read(cameraProvider.notifier).addCameras();
    initMeeting();
  }

  initMeeting() async {
    client
        .addMeetingRoomEventsListener(ref.read(meetingStateProvider.notifier));
    client.addParticipantEventsListener(
        ref.read(participantStateProvider(context).notifier));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(meetingStateProvider);
    final pageIndex = ref.watch(meetingPageProvider);
    ref.listen(meetingStateProvider, (previous, next) {
      debugPrint("Current State :: ${next.runtimeType}");
      switch (next.runtimeType) {
        case MeetingInitCompleted:
          client.joinRoom();
          // checkMeetingState();
          break;
        case MeetingRoomJoinCompleted:
          ref.read(meetingPageProvider.notifier).changePageIndex(2);
          break;
        case MeetingRoomLeaveCompleted:
          ref.read(meetingPageProvider.notifier).changePageIndex(3);
          break;
        default:
          ref.read(meetingPageProvider.notifier).changePageIndex(1);
          break;
      }
    });
    return pages[pageIndex];
  }

  // checkMeetingState() {
  //   Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (client.meta.meetingTitle.isNotEmpty) {
  //       ref
  //           .read(meetingStateProvider.notifier)
  //           .changeState(MeetingRoomJoinCompleted());
  //     }
  //     timer.cancel();
  //   });
  // }
}
