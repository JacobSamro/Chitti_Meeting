import 'package:camera/camera.dart';
import 'package:chitti_meeting/common/widgets/custom_button.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TestCamera extends ConsumerStatefulWidget {
  const TestCamera({super.key});

  @override
  ConsumerState<TestCamera> createState() => _TestCameraState();
}

class _TestCameraState extends ConsumerState<TestCamera> {
  late final CameraController controller;
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
    await ref.read(cameraProvider.notifier).addCameras();
    controller = ref.read(cameraProvider);
    await controller.initialize();
    cameraPermission = true;
    setState(() {});
  }

  @override
  void dispose() {
    // controller.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final state = ref.watch(meetingStateProvider);
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
                  width: 300,
                  height: 168,
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
                  width: 300,
                  height: 52,
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
                GestureDetector(
                  onTap: () {
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enter User Name")));
                      return;
                    }
                    if (!cameraPermission) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Enable Camera")));
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });
                    locator<MeetingRepositories>()
                        .addParticipant(nameController.text, isVideoOn);
                    isLoading = false;
                  },
                  child: CustomButton(
                    height: 52,
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
