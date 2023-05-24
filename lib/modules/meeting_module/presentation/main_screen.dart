import 'package:chitti_meeting/common/widgets/custom_bottom_navigation.dart';
import 'package:chitti_meeting/modules/chat_module/presentation/chat_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/participants_screen.dart';
import 'package:chitti_meeting/modules/view_module/presentation/gallery_view.dart';
import 'package:chitti_meeting/modules/view_module/presentation/speaker_view.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../view_module/presentation/standard_view.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final DyteMobileClient client = locator<DyteMobileClient>();
  Widget currentScreen = const StandardView();
  bool isFullScreen = false;
  @override
  void dispose() {
    super.dispose();
    locator<VideoPlayerController>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigation(
        items: [
          CustomBottomNavigationItem(
            label: isFullScreen ? "Exit" : "Full Screen",
            iconPath: "assets/icons/full_screen.png",
          ),
          CustomBottomNavigationItem(
            label: client.localUser.videoEnabled ? "Video On" : "Video Off",
            iconPath: client.localUser.videoEnabled
                ? "assets/icons/video.png"
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
          final DyteLocalUser localUser = client.localUser;
          switch (value) {
            case "Video On":
              localUser.videoEnabled = false;
              setState(() {});
              await localUser.disableVideo();
              // ref.read(cameraProvider.notifier).toggleVideo();
              break;
            case "Video Off":
              setState(() {
                localUser.videoEnabled = true;
              });
              await localUser.enableVideo();
              // ref.read(cameraProvider.notifier).toggleVideo();
              break;
            case "Mic On":
              localUser.audioEnabled
                  ? localUser.disableAudio()
                  : localUser.enableAudio();
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
                              setState(() {
                                currentScreen = const StandardView();
                              });
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
                                setState(() {
                                  currentScreen = const GalleryView();
                                });
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
                              setState(() {
                                currentScreen = const SpeakerView();
                              });
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
                // DeviceOrientation.portraitUp,
                DeviceOrientation.landscapeLeft,
              ]);
              setState(() {
                currentScreen = const SpeakerView();
                isFullScreen = true;
              });
              break;
            case "Exit":
              SystemChrome.setPreferredOrientations([
                // DeviceOrientation.portraitUp,
                DeviceOrientation.portraitUp,
              ]);
              setState(() {
                currentScreen = const StandardView();
                isFullScreen = false;
              });
              break;
            case "Leave":
              client.leaveRoom();

              break;
            default:
              break;
          }
        },
      ),
      body: currentScreen,
    );
  }
}
