import 'package:chitti_meeting/common/widgets/custom_bottom_navigation.dart';
import 'package:chitti_meeting/modules/view_module/presentation/gallery_view.dart';
import 'package:chitti_meeting/modules/view_module/presentation/speaker_view.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../view_module/presentation/standard_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final DyteMobileClient client = locator<DyteMobileClient>();
  Widget currentScreen = const StandardView();

  @override
  void dispose() {
    super.dispose();
    locator<VideoPlayerController>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final DyteLocalUser localUser = client.localUser;
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigation(
        items: const [
          CustomBottomNavigationItem(
            label: "Full Screen",
            iconPath: "assets/icons/full_screen.png",
          ),
          CustomBottomNavigationItem(
            label: "Video On",
            iconPath: "assets/icons/video.png",
          ),
          CustomBottomNavigationItem(
            label: "Mic On",
            iconPath: "assets/icons/mic.png",
          ),
          CustomBottomNavigationItem(
            label: "Chat",
            iconPath: "assets/icons/message.png",
          ),
          CustomBottomNavigationItem(
            label: "Switch View",
            iconPath: "assets/icons/view.png",
          ),
          CustomBottomNavigationItem(
            label: "Settings",
            iconPath: "assets/icons/settings.png",
          ),
          CustomBottomNavigationItem(
            label: "Leave",
            iconPath: "assets/icons/call_outline.png",
          ),
          CustomBottomNavigationItem(
            label: "Participants",
            iconPath: "assets/icons/people.png",
          ),
        ],
        onChanged: (value) async {
          switch (value) {
            case "Video On":
              localUser.videoEnabled
                  ? await localUser.disableVideo()
                  : await localUser.enableVideo();
              localUser.videoEnabled = !localUser.videoEnabled;
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
              break;
            case "Settings":
              break;
            case "Participants":
              break;
            case "Full Screen":
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
