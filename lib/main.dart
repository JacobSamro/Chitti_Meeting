import 'package:chitti_meeting/common/constants/app_theme_data.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/main_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/meeting_ended_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/onboard_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/test_camera_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:chitti_meeting/routes.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'modules/meeting_module/states/meeting_states.dart';

void main() {
  setup();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Chitti Meet',
      debugShowCheckedModeBanner: false,
      theme: appThemeData,
      routerConfig: router,
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.hashId});
  final String hashId;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<Widget> pages = [];
  @override
  void initState() {
    super.initState();
    ref.read(meetingStateProvider.notifier).createListener();
    debugPrint("Hash Id :: ${widget.hashId}");
    pages = <Widget>[
      widget.hashId.isNotEmpty
          ? TestCamera(hashId: widget.hashId)
          : const OnBoradScreen(),
      Center(
        child: GestureDetector(
            onTap: () {}, child: const CircularProgressIndicator()),
      ),
      const MainScreen(),
      const MeetingEndedScreen()
    ];
    ref.read(cameraProvider.notifier).addCameras();
    ref.read(meetingStateProvider.notifier).listen(context);
  }

  @override
  void dispose() {
    ref.read(meetingStateProvider.notifier).removeListener();
    ref.read(cameraProvider).value.isInitialized
        ? ref.read(cameraProvider).dispose()
        : null;
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
