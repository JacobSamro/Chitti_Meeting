import 'dart:async';
import 'package:chitti_meeting/common/widgets/custom_bottom_navigation.dart';
import 'package:chitti_meeting/common/widgets/custom_button.dart';
import 'package:chitti_meeting/common/widgets/custom_card.dart';
import 'package:chitti_meeting/modules/chat_module/presentation/chat_screen.dart';
import 'package:chitti_meeting/modules/chat_module/providers/chat_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/participants_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:chitti_meeting/modules/view_module/providers/view_provider.dart';
import 'package:chitti_meeting/modules/view_module/widgets/custom_video_player.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../view_module/presentation/view_screen.dart';
import '../providers/meeting_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final Room room = locator<Room>();
  late Stopwatch _stopwatch;
  @override
  void initState() {
    super.initState();

    _stopwatch = Stopwatch();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(participantProvider.notifier).addLocalParticipantTrack();
      ref
          .read(chatProvider.notifier)
          .listenMessage('96017f1b-fcf4-441c-9f4c-56eb28496ece');
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ViewType viewType = ref.watch(viewProvider);
    return Scaffold(
      appBar: viewType != ViewType.fullScreen
          ? AppBar(
              title: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name.toString(),
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    CustomTimer(stopwatch: _stopwatch)
                  ],
                ),
              ),
            )
          : null,
      body: viewType != ViewType.fullScreen
          ? const Column(
              children: [Expanded(child: ViewScreen()), NavigationBar()],
            )
          : SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  const CustomVideoPlayer(
                      height: double.infinity,
                      src:
                          'https://streameggs.net/0ae71bda-4d2f-4961-9ced-e6d21ede69e6/master.m3u8'),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const NavigationBar()),
                  ),
                ],
              ),
            ),
    );
  }
}

class CustomTimer extends StatefulWidget {
  const CustomTimer({
    super.key,
    required this.stopwatch,
  });
  final Stopwatch stopwatch;
  @override
  State<CustomTimer> createState() => _CustomTimerState();
}

class _CustomTimerState extends State<CustomTimer> {
  late Timer timer;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    widget.stopwatch.start();
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final duration =
        Duration(milliseconds: widget.stopwatch.elapsedMilliseconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        '$twoDigitMinutes:$twoDigitSeconds time',
        style: textTheme.displaySmall?.copyWith(fontSize: 10),
      ),
    );
  }
}

class NavigationBar extends ConsumerStatefulWidget {
  const NavigationBar({super.key});

  @override
  ConsumerState<NavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends ConsumerState<NavigationBar> {
  @override
  void initState() {
    super.initState();
    ref.read(meetingStateProvider.notifier).listenTrack(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final Room room = locator<Room>();
    final ViewType type = ref.watch(viewProvider);
    return CustomBottomNavigation(
      items: [
        CustomBottomNavigationItem(
          label: type == ViewType.fullScreen ? "Exit" : "Full Screen",
          iconPath: "assets/icons/full_screen.png",
        ),
        CustomBottomNavigationItem(
          label: room.localParticipant!.isCameraEnabled()
              ? "Video On"
              : "Video Off",
          iconPath: room.localParticipant!.isCameraEnabled()
              ? 'assets/icons/video.png'
              : "assets/icons/video_off.png",
        ),
        const CustomBottomNavigationItem(
          label: "Mic Off",
          iconPath: "assets/icons/mic_off.png",
        ),
        const CustomBottomNavigationItem(
          label: "Chat",
          badge: true,
          iconPath: "assets/icons/message.png",
        ),
        const CustomBottomNavigationItem(
          label: "Switch View",
          iconPath: "assets/icons/view.png",
        ),
        const CustomBottomNavigationItem(
          label: "Settings",
          iconPath: "assets/icons/settings.png",
        ),
        const CustomBottomNavigationItem(
          label: "Leave",
          iconPath: "assets/icons/call_outline.png",
        ),
        const CustomBottomNavigationItem(
          label: "Participants",
          iconPath: "assets/icons/people.png",
        ),
      ],
      onChanged: (value) async {
        switch (value) {
          case "Video On":
            await room.localParticipant?.setCameraEnabled(false);
            break;
          case "Video Off":
            room.localParticipant?.setCameraEnabled(true);
            break;
          case "Mic Off":
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Mic was disabled by the host")));
            break;
          case "Switch View":
            showModalBottomSheet(
                context: context,
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                        width: 1, color: Colors.white.withOpacity(0.1))),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(viewProvider.notifier)
                                .changeViewType(ViewType.standard);
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Standard View",
                              style: textTheme.labelSmall,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(viewProvider.notifier)
                                  .changeViewType(ViewType.gallery);
                              Navigator.pop(context);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                "Gallery View",
                                style: textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(viewProvider.notifier)
                                .changeViewType(ViewType.speaker);
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              "Speaker View",
                              style: textTheme.labelSmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                });
            break;
          case "Chat":
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ChatScreen()));
            break;
          case "Settings":
            break;
          case "Participants":
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ParticipantsScreen()));
            break;
          case "Full Screen":
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.landscapeLeft,
            ]);
            ref.read(viewProvider.notifier).changeViewType(ViewType.fullScreen);
            break;
          case "Exit":
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            ref.read(viewProvider.notifier).changeViewType(ViewType.standard);

            break;
          case "Leave":
            showDialog(
                barrierColor: Colors.black,
                context: context,
                builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      content: CustomCard(
                        content: "Are you sure to leave?",
                        iconPath: 'assets/icons/cross_mark.png',
                        actions: [
                          GestureDetector(
                            onTap: () async {
                              ref.invalidate(participantProvider);
                              ref.invalidate(viewProvider);
                              await room.disconnect();
                              await locator.reset();
                              Navigator.pop(context);
                            },
                            child: CustomButton(
                              width: 85,
                              height: 45,
                              child: Center(
                                child: Text(
                                  "Yes",
                                  style: textTheme.labelMedium
                                      ?.copyWith(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: CustomButton(
                              width: 85,
                              height: 45,
                              child: Center(
                                child: Text(
                                  "No",
                                  style: textTheme.labelMedium
                                      ?.copyWith(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
            break;
          default:
            break;
        }
      },
    );
  }
}
