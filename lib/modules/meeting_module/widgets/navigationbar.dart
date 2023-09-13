import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chitti_meet/modules/meeting_module/widgets/custom_dropdown.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../common/widgets/custom_bottom_navigation.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_card.dart';
import '../../../utils/utils.dart';
import '../../../common/widgets/custom_timer.dart';
import '../../../common/widgets/dropdown_item.dart';
import '../../../services/locator.dart';
import '../../../services/responsive.dart';
import '../../chat_module/presentation/chat_screen.dart';
import '../../chat_module/providers/chat_provider.dart';
import '../../view_module/models/view_state.dart';
import '../../view_module/providers/camera_provider.dart';
import '../../view_module/providers/view_provider.dart';
import '../models/workshop_model.dart';
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
  late final Room room;
  @override
  void initState() {
    super.initState();
    room = locator<Room>();
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

    final ViewState viewState = ref.watch(viewProvider);
    final Workshop workshop = ref.watch(workshopDetailsProvider);
    final ViewType type = viewState.viewType;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    final bool isDesktop = responsiveDevice == ResponsiveDevice.desktop;
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
          suffixIcon: GestureDetector(
              onTap: () async {
                final videoDevices = await Hardware.instance.videoInputs();
                // ignore: use_build_context_synchronously
                showModalBottomSheet(
                    context: context,
                    barrierColor: Colors.white.withOpacity(0),
                    backgroundColor: Colors.white.withOpacity(0),
                    constraints: BoxConstraints(
                        maxWidth: width > 800 ? 300 : double.infinity),
                    builder: (context) {
                      return CustomDropDown(
                        title: "Video Input",
                        value: room.selectedVideoInputDeviceId!,
                        items: videoDevices
                            .map((e) => CustomDropDownItem(
                                value: e.deviceId,
                                label:
                                    e.label.isEmpty ? "In build Cam" : e.label))
                            .toList(),
                        onChanged: (device) async {
                          Navigator.pop(context);
                          await room.setVideoInputDevice(
                              videoDevices.firstWhere(
                                  (element) => element.deviceId == device));
                        },
                      );
                    });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Image.asset(
                  'assets/icons/arrow_up.png',
                  width: 14,
                  height: 14,
                ),
              )),
        ),
        CustomBottomNavigationItem(
          label: room.localParticipant!.isMicrophoneEnabled()
              ? "Mic On"
              : "Mic Off",
          iconPath: room.localParticipant!.isMicrophoneEnabled()
              ? "assets/icons/mic.png"
              : "assets/icons/mic_off.png",
          suffixIcon: GestureDetector(
              onTap: () async {
                final audioDevice = await Hardware.instance.audioInputs();
                // ignore: use_build_context_synchronously
                showModalBottomSheet(
                    context: context,
                    barrierColor: Colors.white.withOpacity(0),
                    backgroundColor: Colors.white.withOpacity(0),
                    constraints: BoxConstraints(
                        maxWidth: width > 800 ? 300 : double.infinity),
                    builder: (context) {
                      return CustomDropDown(
                        title: "Audio Input",
                        value: room.selectedAudioInputDeviceId!,
                        items: audioDevice
                            .map((e) => CustomDropDownItem(
                                value: e.deviceId,
                                label: e.label.isEmpty
                                    ? "In build Microphone"
                                    : e.label))
                            .toList(),
                        onChanged: (device) async {
                          Navigator.pop(context);
                          await room.setAudioInputDevice(audioDevice.firstWhere(
                              (element) => element.deviceId == device));
                        },
                      );
                    });
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Image.asset(
                  'assets/icons/arrow_up.png',
                  width: 14,
                  height: 14,
                ),
              )),
        ),
        !kIsWeb &&
                defaultTargetPlatform == TargetPlatform.windows &&
                workshop.isHost!
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
            await ref.read(cameraProvider).dispose();
            await room.localParticipant?.setCameraEnabled(false);
            break;
          case "Video Off":
            room.localParticipant!.isScreenShareEnabled()
                // ignore: use_build_context_synchronously
                ? context.showCustomSnackBar(
                    content: "Screen Share is enabled",
                    iconPath: 'assets/icons/info.png')
                : room.localParticipant?.setCameraEnabled(true);
            break;
          case "Mic Off":
            workshop.isHost!
                ? await room.localParticipant?.setMicrophoneEnabled(true)

                // ignore: use_build_context_synchronously
                : context.showCustomSnackBar(
                    content: "Mic was disabled by Host",
                    iconPath: 'assets/icons/mic_off.png');
            break;
          case "Mic On":
            await room.localParticipant?.setMicrophoneEnabled(false);
            break;
          case "Switch View":
            // ignore: use_build_context_synchronously
            showModalBottomSheet(
                context: context,
                barrierColor: Colors.white.withOpacity(0),
                backgroundColor: Colors.white.withOpacity(0),
                constraints: BoxConstraints(
                    maxWidth: width > 800 ? 300 : double.infinity),
                builder: (context) {
                  return CustomDropDown(
                    title: "Views",
                    value: ref.read(viewProvider).viewType.name.toString(),
                    items: [
                      CustomDropDownItem(
                        label: "Standard View",
                        value: 'standard',
                      ),
                      CustomDropDownItem(
                        label: "Gallery View",
                        value: 'gallery',
                      ),
                      CustomDropDownItem(
                        label: "Speaker View",
                        value: 'speaker',
                      )
                    ],
                    onChanged: (String value) {
                      final type = ViewType.values
                          .firstWhere((element) => element.name == value);
                      ref.read(viewProvider.notifier).changeViewType(type);
                      Navigator.pop(context);
                    },
                  );
                });

            break;
          case "Chat":
            if (responsiveDevice != ResponsiveDevice.desktop) {
              if (type == ViewType.fullScreen) {
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
              ref.read(viewProvider.notifier).openChatInDesktop(true);
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ),
              );
              return;
            }
            if (viewState.viewType == ViewType.fullScreen) {
              if (kIsWeb) {
                html.document.exitFullscreen();
              }
              ref.read(viewProvider.notifier).changeViewType(ViewType.standard);
              ref.read(viewProvider.notifier).openChatInDesktop(true);
              return;
            }
            ref.read(viewProvider.notifier).openChatInDesktop(!viewState.chat);
            break;
          case "Participants":
            if (responsiveDevice != ResponsiveDevice.desktop) {
              if (type == ViewType.fullScreen) {
                await SystemChrome.setPreferredOrientations([
                  DeviceOrientation.portraitUp,
                ]);
              }
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParticipantsScreen(),
                ),
              );
              return;
            }
            if (viewState.viewType == ViewType.fullScreen) {
              if (kIsWeb) {
                html.document.exitFullscreen();
              }
              ref.read(viewProvider.notifier).changeViewType(ViewType.standard);
              ref.read(viewProvider.notifier).openParticipantsInDesktop(true);
              return;
            }
            ref
                .read(viewProvider.notifier)
                .openParticipantsInDesktop(!viewState.participants);
            break;
          case "Full Screen":
            if (kIsWeb) {
              html.document.documentElement?.requestFullscreen();
            }
            if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
              appWindow.isMaximized ? null : appWindow.maximize();
            }
            if (!kIsWeb) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
            }
            ref.read(viewProvider.notifier).changeViewType(ViewType.fullScreen);
            if (responsiveDevice != ResponsiveDevice.desktop && !kIsWeb) {
              // ignore: use_build_context_synchronously
              context.openFloatingNavigationBar();
            }
            break;
          case "Exit":
            if (!kIsWeb) {
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.portraitUp,
              ]);
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            }
            if (kIsWeb) {
              html.document.exitFullscreen();
            }
            // ignore: use_build_context_synchronously
            // Navigator.pop(context);
            ref.read(viewProvider.notifier).changeViewType(ViewType.standard);

            break;
          case "Share Screen":
            try {
              // ignore: use_build_context_synchronously
              final source = await showDialog(
                context: context,
                builder: (context) => ScreenSelectDialog(),
              );
              if (source == null) {
                debugPrint('cancelled screenshare');
                return;
              }
              final LocalVideoTrack track =
                  await LocalVideoTrack.createScreenShareTrack(
                ScreenShareCaptureOptions(
                  sourceId: source.id,
                  maxFrameRate: 15.0,
                ),
              );

              await room.localParticipant?.publishVideoTrack(track,
                  publishOptions: const VideoPublishOptions(simulcast: false));
              await room.localParticipant?.setScreenShareEnabled(true);
            } catch (e) {
              throw Exception(e);
            }
            break;
          case "Stop Sharing":
            try {
              // ignore: use_build_context_synchronously
              showDialog(
                  barrierColor: Colors.black,
                  context: context,
                  builder: (context) => AlertDialog(
                        backgroundColor: Colors.black,
                        contentPadding: const EdgeInsets.all(0),
                        insetPadding: const EdgeInsets.all(0),
                        content: CustomCard(
                          content: Text(
                            "Are you sure to Stop?",
                            textAlign: TextAlign.center,
                            style: textTheme.titleMedium,
                          ),
                          iconPath: 'assets/icons/cross_mark.png',
                          actions: [
                            GestureDetector(
                              onTap: () async {
                                Navigator.pop(context);
                                await room.localParticipant
                                    ?.setScreenShareEnabled(false);
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
            } catch (e) {
              throw Exception(e);
            }
            break;
          case "Leave":
            // ignore: use_build_context_synchronously
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
                              if (type == ViewType.fullScreen) {
                                ref
                                    .read(viewProvider.notifier)
                                    .changeViewType(ViewType.standard);
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.portraitUp,
                                ]);
                              }
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
