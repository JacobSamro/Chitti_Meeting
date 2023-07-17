import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../services/locator.dart';
import '../../../services/responsive.dart';
import '../../view_module/providers/camera_provider.dart';
import '../repositories/meeting_respositories.dart';

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
  bool isVideoOn = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    hashId = TextEditingController();
  }

  initCamera() async {
    try {
      await ref.read(cameraProvider.notifier).addCameras();
      controller = ref.read(cameraProvider);
      await controller.initialize();
      cameraPermission = true;
      setState(() {});
    } catch (error) {
      throw Exception(error);
    }
  }

  @override
  void dispose() {
    // controller.dispose();
    nameController.dispose();
    hashId.dispose();
    isVideoOn ? controller.dispose() : null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width:
                      responsiveDevice != ResponsiveDevice.mobile ? 480 : 300,
                  height:
                      responsiveDevice != ResponsiveDevice.mobile ? 270 : 168,
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                        image: AssetImage('assets/images/background.png'),
                        fit: BoxFit.cover),
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
                              ref.read(cameraProvider.notifier).addCameras();
                              isVideoOn = true;
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
                                    style: textTheme.titleSmall
                                        ?.copyWith(color: Colors.black),
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
                                      isVideoOn
                                          ? await controller.dispose()
                                          : await initCamera();
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
                                        isVideoOn
                                            ? "assets/icons/video.png"
                                            : "assets/icons/video_off.png",
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
                SizedBox(
                  width:
                      responsiveDevice != ResponsiveDevice.mobile ? 480 : 300,
                  height: responsiveDevice != ResponsiveDevice.mobile ? 68 : 52,
                  child: TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        hintStyle: textTheme.labelSmall?.copyWith(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width:
                      responsiveDevice != ResponsiveDevice.mobile ? 480 : 300,
                  height: responsiveDevice != ResponsiveDevice.mobile ? 68 : 52,
                  child: TextField(
                      controller: hashId,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: "Enter your meeting ID",
                        hintStyle: textTheme.labelSmall?.copyWith(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                            width: 0.5,
                          ),
                        ),
                      )),
                ),
                const SizedBox(
                  height: 16,
                ),
                !isLoading
                    ? GestureDetector(
                        onTap: () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Enter User Name")));
                            return;
                          }
                          if (hashId.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Enter meeting ID")));
                            return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          await locator<MeetingRepositories>().addParticipant(
                              nameController.text, isVideoOn, ref);
                          isLoading = false;
                        },
                        child: CustomButton(
                          height: responsiveDevice != ResponsiveDevice.mobile
                              ? 68
                              : 52,
                          width: responsiveDevice != ResponsiveDevice.mobile
                              ? 480
                              : 300,
                          child: Center(
                            child: Text(
                              "Join the Workshop",
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
      ),
    );
  }
}