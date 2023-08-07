import 'package:chitti_meeting/common/widgets/custom_timer.dart';
import 'package:chitti_meeting/modules/meeting_module/models/workshop_model.dart';
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
import 'package:flutter_webrtc/flutter_webrtc.dart';

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
    final Workshop workshop = ref.watch(workshopDetailsProvider);
    final ViewType type = viewState.viewType;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    final bool isDesktop = responsiveDevice == ResponsiveDevice.desktop;
    debugPrint(room.localParticipant!.isScreenShareEnabled().toString());
    return CustomBottomNavigation(
      leading: isDesktop
          ? Row(
              children: [
                Flexible(
                  child: Text(
                    workshop.workshopName!,
                    style: textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                const CustomTimer()
              ],
            )
          : null,
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
        CustomBottomNavigationItem(
          label: room.localParticipant!.isMicrophoneEnabled()
              ? "Mic On"
              : "Mic Off",
          iconPath: room.localParticipant!.isMicrophoneEnabled()
              ? "assets/icons/mic.png"
              : "assets/icons/mic_off.png",
        ),
        !kIsWeb && defaultTargetPlatform == TargetPlatform.windows
            ? CustomBottomNavigationItem(
                label: !room.localParticipant!.isScreenShareEnabled()
                    ? "Share Screen"
                    : "Stop Sharing",
                iconPath: !room.localParticipant!.isScreenShareEnabled()
                    ? "assets/icons/screen_share.png"
                    : "assets/icons/stop_screen_share.png",
              )
            : null,
        isDesktop ? null : chatNavigationItem(ref),
        type == ViewType.fullScreen
            ? null
            : const CustomBottomNavigationItem(
                label: "Switch View",
                iconPath: "assets/icons/view.png",
              ),
        const CustomBottomNavigationItem(
          label: "Leave",
          iconPath: "assets/icons/call_outline.png",
        ),
        isDesktop ? null : participantNavigationItem(ref)
      ],
      actions: isDesktop
          ? [chatNavigationItem(ref), participantNavigationItem(ref)]
          : null,
      onChanged: (value) async {
        switch (value) {
          case "Video On":
            await room.localParticipant?.setCameraEnabled(false);
            break;
          case "Video Off":
            room.localParticipant!.isScreenShareEnabled()
                ? Utils.showCustomSnackBar(
                    buildContext: context,
                    content: "Screen Share is enabled",
                    iconPath: 'assets/icons/info.png')
                : room.localParticipant?.setCameraEnabled(true);
            break;
          case "Mic Off":
            workshop.isHost!
                ? await room.localParticipant?.setMicrophoneEnabled(true)
                : Utils.showCustomSnackBar(
                    buildContext: context,
                    content: "Mic was disabled by Host",
                    iconPath: 'assets/icons/mic_off.png');
            break;
          case "Mic On":
            await room.localParticipant?.setMicrophoneEnabled(false);
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
          case "Share Screen":
            try {
              final source = await showDialog<DesktopCapturerSource>(
                context: context,
                builder: (context) => ScreenSelectDialog(),
              );
              if (source == null) {
                debugPrint('cancelled screenshare');
                return;
              }
              debugPrint('DesktopCapturerSource: ${source.id}');
              final LocalVideoTrack track =
                  await LocalVideoTrack.createScreenShareTrack(
                ScreenShareCaptureOptions(
                  sourceId: source.id,
                  maxFrameRate: 15.0,
                ),
              );
              await room.localParticipant?.publishVideoTrack(track);
              await room.localParticipant?.setScreenShareEnabled(true);
            } catch (e) {
              debugPrint('could not publish screen sharing: $e');
            }
            break;
          case "Stop Sharing":
            try {
              await room.localParticipant?.setScreenShareEnabled(false);
            } catch (e) {
              throw Exception(e);
            }
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
                        content: Text(
                          "Are you sure to leave?",
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium,
                        ),
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
