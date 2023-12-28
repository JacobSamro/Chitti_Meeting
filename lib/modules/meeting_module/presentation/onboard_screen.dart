import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_card.dart';
import '../../../common/widgets/custom_inputfield.dart';
import '../../../services/locator.dart';
import '../../../services/responsive.dart';
import '../../../utils/utils.dart';
import '../../view_module/providers/camera_provider.dart';
import '../providers/meeting_provider.dart';
import '../repositories/meeting_respositories.dart';
import '../states/meeting_states.dart';

class OnBoradScreen extends ConsumerStatefulWidget {
  const OnBoradScreen({super.key});

  @override
  ConsumerState<OnBoradScreen> createState() => _OnBoardScreenState();
}

class _OnBoardScreenState extends ConsumerState<OnBoradScreen> {
  late CameraController controller;
  bool cameraPermission = false;
  late final TextEditingController nameController;
  late final TextEditingController hashId;
  late final TextEditingController passcode;
  bool isVideoOn = false;
  bool isLoading = false;
  String buttonText = 'Join Meeting';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    hashId = TextEditingController();
    passcode = TextEditingController();
    if (!locator.isRegistered<Room>()) {
      locator.registerLazySingleton<Room>(() => Room());
    }
    if (ref.read(meetingStateProvider.notifier).listener.isDisposed) {
      ref.read(meetingStateProvider.notifier).createListener();
      ref.read(meetingStateProvider.notifier).listen(context);
    }
    nameController.addListener(() {
      if (nameController.text.split('.').last == 'host') {
        if (passcode.text.isEmpty) {
          setState(() {
            buttonText = 'Confirm Passcode';
          });
        }
      } else {
        passcode.clear();
        setState(() {
          buttonText = 'Join Meeting';
        });
      }
    });
    passcode.addListener(() {
      if (passcode.text.isNotEmpty) {
        setState(() {
          buttonText = 'Join Meeting';
        });
      } else {
        setState(() {
          buttonText = 'Confirm Passcode';
        });
      }
    });
  }

  Future<bool> getPermissions() async {
    if (Platform.isIOS) return true;
    await Permission.camera.request();
    await Permission.microphone.request();
    // await Permission.bluetoothConnect.request();

    while ((await Permission.camera.isDenied)) {
      await Permission.camera.request();
    }
    while ((await Permission.microphone.isDenied)) {
      await Permission.microphone.request();
    }
    // while ((await Permission.bluetoothConnect.isDenied)) {
    //   await Permission.bluetoothConnect.request();
    // }
    return true;
  }

  initCamera() async {
    try {
      await ref.read(cameraProvider.notifier).addCameras();
      controller = ref.read(cameraProvider);
      await controller.initialize();
      cameraPermission = true;
      setState(() {
        isVideoOn = true;
      });
    } catch (error) {
      if (kIsWeb) {
        // ignore: use_build_context_synchronously
        context.handleMediaError(error).then((value) async {
          if (value) {
            await controller.initialize();
            setState(() {
              cameraPermission = true;
              isVideoOn = true;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    hashId.dispose();
    passcode.dispose();
    isVideoOn ? controller.dispose() : null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final ResponsiveDevice responsiveDevice = Responsive().getDeviceType(context);

    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: responsiveDevice != ResponsiveDevice.mobile ? 480 : 300,
            height: responsiveDevice != ResponsiveDevice.mobile ? 270 : 168,
            decoration: BoxDecoration(
              image: const DecorationImage(image: AssetImage('assets/images/background.png'), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: !cameraPermission
                ? Center(
                    child: GestureDetector(
                      onTap: () {
                        // ref.read(cameraProvider.notifier).addCameras();
                        initCamera();
                      },
                      child: CustomButton(
                        width: 177,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Enable Camera",
                              style: textTheme.titleSmall?.copyWith(color: Colors.black),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                              color: Colors.black,
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                            width: double.infinity,
                            child: isVideoOn
                                ? CameraPreview(controller)
                                : Container(
                                    color: Colors.black,
                                  )),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                "assets/icons/mic_off.png",
                                width: 20,
                                height: 20,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (!isVideoOn) {
                                  await initCamera();
                                  return;
                                }
                                await controller.dispose();
                                isVideoOn = !isVideoOn;
                                setState(() {});
                              },
                              child: Container(
                                height: 40,
                                width: 40,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  isVideoOn ? "assets/icons/video.png" : "assets/icons/video_off.png",
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
          ),
          const SizedBox(
            height: 28,
          ),
          CustomInputField(controller: nameController, label: "Enter your name"),
          const SizedBox(
            height: 10,
          ),
          CustomInputField(
            controller: hashId,
            label: "Enter your meeting ID",
          ),
          const SizedBox(
            height: 24,
          ),
          !isLoading
              ? GestureDetector(
                  onTap: () async {
                    bool res = await getPermissions();
                    if (res) {
                      if (nameController.text.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter User Name")));
                        return;
                      }
                      if (hashId.text.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter meeting ID")));
                        return;
                      }
                      if (nameController.text.split('.').last == 'host' && passcode.text.isEmpty) {
                        // ignore: use_build_context_synchronously
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierColor: Colors.black,
                          builder: (dialogContext) => AlertDialog(
                            backgroundColor: Colors.black,
                            contentPadding: const EdgeInsets.all(0),
                            insetPadding: const EdgeInsets.all(0),
                            content: CustomCard(
                                iconPath: "assets/icons/passcode.png",
                                content: Column(
                                  children: [
                                    const Text("Confirm Passcode to join as Host"),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    CustomInputField(controller: passcode, obscureText: true, label: "Passcode"),
                                  ],
                                ),
                                actions: [
                                  GestureDetector(
                                    onTap: () {
                                      if (passcode.text.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Passcode")));
                                        Navigator.pop(context);
                                        setState(() {
                                          buttonText = 'Join Meeting';
                                        });
                                        return;
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: CustomButton(
                                      child: Center(
                                        child: Text(
                                          "Continue",
                                          style: textTheme.titleSmall?.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      passcode.clear();
                                    },
                                    child: CustomButton(
                                      color: Colors.white.withOpacity(0.2),
                                      child: Center(
                                        child: Text("Cancel", style: textTheme.titleSmall),
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        );
                        return;
                      }
                      if (!mounted) return;
                      FocusScope.of(context).unfocus();
                      setState(() {
                        isLoading = true;
                      });
                      ref.read(participantProvider.notifier).setParticipantName(nameController.text);
                      final bool canConnect = await ref.read(workshopDetailsProvider.notifier).getWorkshopDetials(hashId.text);
                      if (canConnect) {
                        if (!context.mounted) return;
                        final bool value = await locator<MeetingRepositories>().addParticipant(context, nameController.text.trim(), passcode.text.trim(), ref.read(workshopDetailsProvider).meetingId.toString(), isVideoOn, ref);
                        if (!value) {
                          // ignore: use_build_context_synchronously
                          context.showCustomSnackBar(content: "Participant unable to join", iconPath: 'assets/icons/info.png');
                          isLoading = false;
                          isVideoOn = false;
                          ref.read(meetingStateProvider.notifier).changeState(RouterInitial());
                        }
                      }
                    }
                  },
                  child: CustomButton(
                    height: 52,
                    width: responsiveDevice != ResponsiveDevice.mobile ? 480 : 300,
                    child: Center(
                      child: Text(
                        buttonText,
                        style: textTheme.titleSmall?.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              : const CircularProgressIndicator(
                  color: Colors.white,
                ),
        ]),
      ),
    );
  }
}
