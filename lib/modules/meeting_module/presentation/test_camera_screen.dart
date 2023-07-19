import 'package:camera/camera.dart';
import 'package:chitti_meeting/common/widgets/custom_button.dart';
import 'package:chitti_meeting/common/widgets/custom_inputfield.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/services/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/meeting_respositories.dart';

class TestCamera extends ConsumerStatefulWidget {
  const TestCamera({super.key, required this.hashId});
  final String hashId;
  @override
  ConsumerState<TestCamera> createState() => _TestCameraState();
}

class _TestCameraState extends ConsumerState<TestCamera> {
  late CameraController controller;
  bool cameraPermission = false;
  late final TextEditingController nameController;
  bool isVideoOn = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
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
    isVideoOn ? controller.dispose() : null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    // final ResponsiveDevice responsiveDevice = ref.read(responsiveProvider);
    // final state = ref.watch(meetingStateProvider);
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
                CustomInputField(
                    controller: nameController, label: "Enter your name"),
                const SizedBox(
                  height: 16,
                ),
                GestureDetector(
                  onTap: () async {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter User Name")));
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });
                    await locator<MeetingRepositories>()
                        .addParticipant(nameController.text, isVideoOn, ref);
                    isLoading = false;
                  },
                  child: CustomButton(
                    height:
                        responsiveDevice != ResponsiveDevice.mobile ? 68 : 52,
                    width:
                        responsiveDevice != ResponsiveDevice.mobile ? 480 : 300,
                    child: Center(
                      child: !isLoading
                          ? Text(
                              "Join the Workshop",
                              style: textTheme.titleSmall?.copyWith(
                                color: Colors.black,
                              ),
                            )
                          : const CircularProgressIndicator(),
                    ),
                  ),
                ),
              ]),
        ),
      ),
    );
  }
}
