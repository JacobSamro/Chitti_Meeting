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
import 'package:video_player/video_player.dart';
import '../../../common/widgets/custom_timer.dart';
import '../../../common/widgets/switch_view_item.dart';
import '../../../services/responsive.dart';
import '../../view_module/models/view_state.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(participantProvider.notifier).addLocalParticipantTrack();
      ref.read(chatProvider.notifier).listenMessage(
          ref.read(workshopDetailsProvider).meetingId.toString());
    });
  }

  @override
  void dispose() {
    locator.unregister<VideoPlayerController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ViewState viewState = ref.watch(viewProvider);
    final ViewType viewType = viewState.viewType;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    return Scaffold(
      appBar: viewType != ViewType.fullScreen
          ? AppBar(
              title: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        room.name.toString(),
                        style: textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      width: 6,
                    ),
                    const CustomTimer()
                  ],
                ),
              ),
            )
          : null,
      body: viewType != ViewType.fullScreen
          ? const Column(
              children: [
                Expanded(flex: 1, child: ViewScreen()),
                NavigationBar()
              ],
            )
          : SizedBox(
              height: double.infinity,
              width: double.infinity,
              child: responsiveDevice != ResponsiveDevice.desktop
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const CustomVideoPlayer(
                            height: double.infinity,
                            src:
                                'https://streameggs.net/0ae71bda-4d2f-4961-9ced-e6d21ede69e6/master.m3u8'),
                        Positioned(
                          bottom: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 30.0),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const NavigationBar()),
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      children: [
                        Expanded(
                          child: CustomVideoPlayer(
                              height: double.infinity,
                              src:
                                  'https://streameggs.net/0ae71bda-4d2f-4961-9ced-e6d21ede69e6/master.m3u8'),
                        ),
                        NavigationBar()
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
                      contentPadding: const EdgeInsets.all(0),
                      insetPadding: EdgeInsets.all(0),
                      content: CustomCard(
                        content: "Are you sure to leave?",
                        iconPath: 'assets/icons/cross_mark.png',
                        actions: [
                          GestureDetector(
                            onTap: () async {
                              ref.invalidate(participantProvider);
                              ref.invalidate(viewProvider);
                              await room.disconnect();
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
