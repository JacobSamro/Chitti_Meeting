import 'package:camera/camera.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/main_screen.dart';
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
    const Center(
      child: Text("Leave"),
    )
  ];
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    ref.read(cameraProvider.notifier).addCameras();
    initMeeting();
  }
  initMeeting() async {
    // final String token = await locator<MeetingRepositories>().addParticipant();
    // client.init(DyteMeetingInfoV2(authToken: token));
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
    ref.watch(meetingStateProvider);
    ref.listen(meetingStateProvider, (previous, next) {
      debugPrint("hello${next.runtimeType}");
      switch (next.runtimeType) {
        case MeetingInitCompleted:
          client.joinRoom();
          break;
        case MeetingRoomJoinCompleted:
          pageIndex = 2;
          break;
        case MeetingRoomLeaveCompleted:
          pageIndex = 3;
          break;
        default:
          pageIndex = 1;
          break;
      }
    });
    return pages[pageIndex];
  }
}
