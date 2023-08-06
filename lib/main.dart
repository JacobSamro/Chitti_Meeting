import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/main_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/meeting_dialogues.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/onboard_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/test_camera_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/waiting_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:chitti_meeting/routes.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'common/constants/constants.dart';
import 'modules/meeting_module/states/meeting_states.dart';

void main() {
  setup();
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    Utils.setWindowSize();
  }
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(meetingStateProvider.notifier).createListener();
    pages = <Widget>[
      widget.hashId.isNotEmpty
          ? TestCamera(hashId: widget.hashId)
          : const OnBoradScreen(),
      const Center(
        child: CircularProgressIndicator(),
      ),
      const MainScreen(),
      const MeetingDialogue(),
      const WaitingScreen()
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
        case MeetingEnded:
          ref.read(meetingPageProvider.notifier).changePageIndex(3);
          break;
        case WaitingRoom:
          ref.read(meetingPageProvider.notifier).changePageIndex(4);
          break;
        default:
          ref.read(meetingPageProvider.notifier).changePageIndex(1);
          break;
      }
    });
    // final buttonColor = WindowButtonColors(iconNormal: Colors.white);
    return Scaffold(
        key: locator<GlobalKey<ScaffoldState>>(),
        appBar: !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
            ? AppBar(
                iconTheme: const IconThemeData(size: 18, color: Colors.white),
                title: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: MoveWindow(
                      child: const Text(
                        "Chitti Meet",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.normal),
                      ),
                    )),
                actions: [
                  MinimizeWindowButton(
                    colors: WindowButtonColors(iconNormal: Colors.white),
                  ),
                  MaximizeWindowButton(
                    colors: WindowButtonColors(iconNormal: Colors.white),
                  ),
                  CloseWindowButton(
                    colors: WindowButtonColors(iconNormal: Colors.white),
                  )
                ],
              )
            : null,
        body: pages[pageIndex]);
  }
}
