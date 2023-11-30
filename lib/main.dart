import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chitti_meet/common/widgets/control_button.dart';
import 'package:chitti_meet/common/widgets/custom_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:video_js/video_js.dart';
import 'package:window_manager/window_manager.dart';
import 'common/constants/constants.dart';
import 'common/widgets/custom_button.dart';
import 'modules/meeting_module/presentation/main_screen.dart';
import 'modules/meeting_module/presentation/meeting_dialogues.dart';
import 'modules/meeting_module/presentation/onboard_screen.dart';
import 'modules/meeting_module/presentation/test_camera_screen.dart';
import 'modules/meeting_module/presentation/waiting_screen.dart';
import 'modules/meeting_module/providers/meeting_provider.dart';
import 'modules/meeting_module/states/meeting_states.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'modules/view_module/providers/camera_provider.dart';
import 'modules/view_module/providers/view_provider.dart';
import 'routes.dart';
import 'services/locator.dart';
import '../../../utils/utils.dart';

void main() async {
  setup();
  // final ProviderContainer providerContainer = ;
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.singleton.initEnvironment(Environment.staging);
  if (kIsWeb) {
    VideoJsResults().init();
    usePathUrlStrategy();
    final String url = Uri.base.path;
    router.go(url);
  }
  if (!kIsWeb) {
    MediaKit.ensureInitialized();
    if (defaultTargetPlatform == TargetPlatform.windows) {
      await windowManager.ensureInitialized();
      Utils.setWindowSize();
    }
  }
  runApp(UncontrolledProviderScope(
      container: locator<ProviderContainer>(), child: const MyApp()));
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
    // ref.read(cameraProvider.notifier).addCameras();
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
    final TextTheme textTheme = Theme.of(context).textTheme;
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
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.black,
                contentPadding: const EdgeInsets.all(0),
                insetPadding: const EdgeInsets.all(0),
                content: CustomCard(
                  content: Text(
                    "Are you sure to Exit?",
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium,
                  ),
                  iconPath: 'assets/icons/cross_mark.png',
                  actions: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      child: CustomButton(
                        width: 85,
                        height: 45,
                        child: Center(
                          child: Text(
                            "Exit",
                            style: textTheme.labelMedium
                                ?.copyWith(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: CustomButton(
                        width: 85,
                        height: 45,
                        color: Colors.white.withOpacity(0.1),
                        child: Center(
                          child: Text(
                            "Cancel",
                            style: textTheme.labelMedium
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
      child: Scaffold(
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
                              color: Colors.white,
                              fontWeight: FontWeight.normal),
                        ),
                      )),
                  actions: [
                    ControlButtton(
                      hoverColor: Colors.white.withOpacity(0.2),
                      iconPath: 'assets/icons/minimize.png',
                      onTap: () => appWindow.minimize(),
                      tooltip: "Minimize",
                    ),
                    ControlButtton(
                        hoverColor: Colors.white.withOpacity(0.2),
                        iconPath: 'assets/icons/resize.png',
                        onTap: () => appWindow.isMaximized
                            ? appWindow.restore()
                            : appWindow.maximize(),
                        tooltip: "Maximize"),
                    ControlButtton(
                      hoverColor: Colors.red[900]!,
                      iconPath: 'assets/icons/close.png',
                      onTap: () => appWindow.close(),
                      tooltip: "Close",
                    ),
                    // const SizedBox(width: 10)
                  ],
                )
              : null,
          body: pages[pageIndex]),
    );
  }
}
