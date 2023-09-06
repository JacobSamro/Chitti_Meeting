import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/main_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/meeting_dialogues.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/onboard_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/test_camera_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/waiting_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:chitti_meeting/modules/view_module/providers/view_provider.dart';
import 'package:chitti_meeting/routes.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';
import 'common/constants/constants.dart';
import 'modules/meeting_module/states/meeting_states.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  setup();
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    usePathUrlStrategy();
    final String url = Uri.base.path;
    router.go(url);
  }
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
    await windowManager.ensureInitialized();
    MediaKit.ensureInitialized();
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
  final GlobalKey<ScaffoldState> scaffoldKey =
      locator<GlobalKey<ScaffoldState>>();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    ref.read(meetingStateProvider.notifier).createListener();
    ref.read(meetingPageProvider.notifier).setMeetingId(widget.hashId);
    ref.read(cameraProvider.notifier).addCameras();
    ref.read(meetingStateProvider.notifier).listen(context);
  }

  void createPages() {
    pages = <Widget>[
      ref.read(meetingPageProvider.notifier).meetingId.isNotEmpty
          ? TestCamera(hashId: widget.hashId)
          : const OnBoradScreen(),
      const Center(
        child: CircularProgressIndicator(),
      ),
      const MainScreen(),
      const MeetingDialogue(),
      const WaitingScreen()
    ];
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
    final ViewType viewType = ref.watch(viewProvider).viewType;
    createPages();
    ref.listen(meetingStateProvider, (previous, next) {
      debugPrint("Current State :: ${next.runtimeType}");
      switch (next.runtimeType) {
        case RouterInitial:
          ref.read(meetingPageProvider.notifier).changePageIndex(0);
          break;
        case MeetingRoomJoinCompleted:
          ref.read(meetingPageProvider.notifier).changePageIndex(2);
          break;
        case MeetingNotFound:
          ref.read(meetingPageProvider.notifier).changePageIndex(3);
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
    return Scaffold(
        key: scaffoldKey,
        appBar: !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.windows &&
                viewType != ViewType.fullScreen
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
                    colors: WindowButtonColors(iconNormal: Colors.grey),
                  ),
                  MaximizeWindowButton(
                    colors: WindowButtonColors(iconNormal: Colors.grey),
                  ),
                  CloseWindowButton(
                    colors: WindowButtonColors(
                        iconNormal: Colors.grey, mouseOver: Colors.red),
                  )
                ],
              )
            : null,
        body: pages[pageIndex]);
  }
}
