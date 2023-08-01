import 'package:chitti_meeting/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_card.dart';
import '../../../common/widgets/switch_view_item.dart';
import '../../../services/locator.dart';
import '../../../services/responsive.dart';
import '../../chat_module/presentation/chat_screen.dart';
import '../../chat_module/providers/chat_provider.dart';
import '../../view_module/models/view_state.dart';
import '../../view_module/providers/view_provider.dart';
import '../presentation/participants_screen.dart';
import '../providers/meeting_provider.dart';
import '../states/meeting_states.dart';
import 'package:universal_html/html.dart' as html;

class CustomNavigationBar extends ConsumerStatefulWidget {
  const CustomNavigationBar({super.key, this.isFloating = false});
  final bool isFloating;
  @override
  ConsumerState<CustomNavigationBar> createState() => _NavigationBarState();
}

class _NavigationBarState extends ConsumerState<CustomNavigationBar> {
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
    final double width = MediaQuery.of(context).size.width;
    final Room room = locator<Room>();
    final ViewState viewState = ref.watch(viewProvider);
    final ViewType type = viewState.viewType;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
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
        chatNavigationItem(ref),
        CustomBottomNavigationItem(
          label: "Switch View",
          iconPath: "assets/icons/view.png",
          visible: type == ViewType.fullScreen ? false : true,
        ),
        const CustomBottomNavigationItem(
          label: "Leave",
          iconPath: "assets/icons/call_outline.png",
        ),
        participantNavigationItem(ref)
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
            Utils.showCustomSnackBar(
                buildContext: context, content: "Mic was disabled by Host",iconPath: 'assets/icons/mic_off.png');
            break;
          case "Switch View":
            showModalBottomSheet(
                context: context,
                barrierColor: Colors.white.withOpacity(0),
                backgroundColor: Colors.white.withOpacity(0),
                constraints: BoxConstraints(
                    maxWidth: width > 800 ? 300 : double.infinity),
                builder: (context) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: width > 800 ? 70 : 0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                        border: Border.all(
                            width: 1, color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchViewItem(
                              label: "Standard View",
                              onTap: () {
                                ref
                                    .read(viewProvider.notifier)
                                    .changeViewType(ViewType.standard);
                                Navigator.pop(context);
                              }),
                          SwitchViewItem(
                              label: "Gallery View",
                              onTap: () {
                                ref
                                    .read(viewProvider.notifier)
                                    .changeViewType(ViewType.gallery);
                                Navigator.pop(context);
                              }),
                          SwitchViewItem(
                              label: "Speaker View",
                              onTap: () {
                                ref
                                    .read(viewProvider.notifier)
                                    .changeViewType(ViewType.speaker);
                                Navigator.pop(context);
                              })
                        ],
                      ),
                    ),
                  );
                });
            break;
          case "Chat":
            if (responsiveDevice != ResponsiveDevice.desktop) {
              if (type == ViewType.fullScreen) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ),
              );
              return;
            }
            if (viewState.viewType == ViewType.fullScreen) {
              ref.read(viewProvider.notifier).changeViewType(ViewType.standard);
              ref.read(viewProvider.notifier).openChatInDesktop(true);
              return;
            }
            ref.read(viewProvider.notifier).openChatInDesktop(!viewState.chat);
            break;
          case "Participants":
            if (responsiveDevice != ResponsiveDevice.desktop) {
              if (type == ViewType.fullScreen) {
                SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParticipantsScreen(),
                ),
              );
              return;
            }
            if (viewState.viewType == ViewType.fullScreen) {
              ref.read(viewProvider.notifier).changeViewType(ViewType.standard);
              ref.read(viewProvider.notifier).openParticipantsInDesktop(true);
              return;
            }
            ref
                .read(viewProvider.notifier)
                .openParticipantsInDesktop(!viewState.participants);
            break;
          case "Full Screen":
            if (!kIsWeb) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            }
            ref.read(viewProvider.notifier).changeViewType(ViewType.fullScreen);
            html.document.documentElement?.requestFullscreen();
            if (responsiveDevice != ResponsiveDevice.desktop && !kIsWeb) {
              Utils.openFloatingNavigationBar(context);
            }
            break;
          case "Exit":
            if (!kIsWeb) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            }
            html.document.exitFullscreen();

            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            ref.read(viewProvider.notifier).changeViewType(ViewType.standard);

            break;
          case "Leave":
            showDialog(
                barrierColor: Colors.black,
                context: context,
                builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      contentPadding: const EdgeInsets.all(0),
                      insetPadding: const EdgeInsets.all(0),
                      content: CustomCard(
                        content: "Are you sure to leave?",
                        iconPath: 'assets/icons/cross_mark.png',
                        actions: [
                          GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                              await room.disconnect();
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

CustomBottomNavigationItem chatNavigationItem(WidgetRef ref) {
  ref.watch(chatProvider);
  final msgCount = ref.watch(unReadMessageProvider);
  return CustomBottomNavigationItem(
    label: "Chat",
    badge: true,
    iconPath: "assets/icons/message.png",
    badgeValue: msgCount,
  );
}

CustomBottomNavigationItem participantNavigationItem(WidgetRef ref) {
  final participantCount = ref.watch(participantProvider);
  return CustomBottomNavigationItem(
      label: "Participants",
      iconPath: "assets/icons/people.png",
      badge: true,
      badgeValue: participantCount.length);
}