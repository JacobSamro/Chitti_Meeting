import 'package:chitti_meeting/modules/meeting_module/presentation/main_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/meeting_ended_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/test_camera_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modules/meeting_module/states/meeting_states.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chitti Meeting',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
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
    ref.read(meetingStateProvider.notifier).createListener();
    ref.read(meetingStateProvider.notifier).listen(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ref.read(responsiveProvider.notifier).deviceType(context);
  }

  @override
  void dispose() {
    ref.read(meetingStateProvider.notifier).removeListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageIndex = ref.watch(meetingPageProvider);
    ref.listen(meetingStateProvider, (previous, next) {
      debugPrint("Current State :: ${next.runtimeType}");
      switch (next.runtimeType) {
        case RouterInitial:
          ref.read(meetingPageProvider.notifier).changePageIndex(0);
          break;
        case MeetingRoomJoinCompleted:
          ref.read(meetingPageProvider.notifier).changePageIndex(2);
          break;
        case MeetingRoomDisconnected:
          ref.read(meetingPageProvider.notifier).changePageIndex(3);
          break;
        default:
          ref.read(meetingPageProvider.notifier).changePageIndex(1);
          break;
      }
    });
    return pages[pageIndex];
  }
}
