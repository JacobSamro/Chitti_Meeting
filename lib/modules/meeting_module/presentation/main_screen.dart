import 'package:chitti_meeting/common/widgets/custom_bottom_navigation.dart';
import 'package:chitti_meeting/modules/chat_module/presentation/chat_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/participants_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:chitti_meeting/modules/view_module/providers/view_provider.dart';
import 'package:chitti_meeting/modules/view_module/widgets/custom_video_player.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:video_player/video_player.dart';

import '../../view_module/presentation/view_screen.dart';
import '../providers/meeting_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final Room room = locator<Room>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(participantProvider.notifier).addLocalParticipantTrack();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final textTheme = Theme.of(context).textTheme;
    final ViewType viewType = ref.watch(viewProvider);
    return Scaffold(
      // appBar: AppBar(
      //   title: Padding(
      //     padding: const EdgeInsets.all(16),
      //     child: Row(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Text(
      //           room.name.toString(),
      //           style: textTheme.bodySmall,
      //         ),
      //         const SizedBox(
      //           width: 6,
      //         ),
      //         Container(
      //           padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      //           decoration: BoxDecoration(
      //             color: Colors.white.withOpacity(0.1),
      //             borderRadius: BorderRadius.circular(50),
      //           ),
      //           child: Text(
      //             'time',
      //             style: textTheme.displaySmall?.copyWith(fontSize: 10),
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
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
                          child: Text(
                            "Standard View",
                            style: textTheme.labelSmall,
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
                            child: Text(
                              "Gallery View",
                              style: textTheme.labelSmall,
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
                          child: Text(
                            "Speaker View",
                            style: textTheme.labelSmall,
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
            await room.localParticipant?.unpublishAllTracks();
            await room.localParticipant?.dispose();
            await room.disconnect();
            ref.invalidate(participantProvider);
            // room.dispose();
            locator<VideoPlayerController>().dispose();
            locator.unregister<VideoPlayerController>();
            break;
          default:
            break;
        }
      },
    );
  }
}
