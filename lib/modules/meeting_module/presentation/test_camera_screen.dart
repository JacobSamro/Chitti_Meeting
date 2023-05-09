import 'package:camera/camera.dart';
import 'package:chitti_meeting/common/widgets/custom_button.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
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
  @override
  void initState() {
    super.initState();
    initCamera();
  }

  initCamera() async {
    final cameras = ref.read(cameraProvider);
    if (cameras.isNotEmpty) {
      controller = CameraController(cameras[1], ResolutionPreset.medium);
      await controller.initialize();
      cameraPermission = true;
      setState(() {});
    }
    return;
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final state = ref.watch(meetingStateProvider);
    // controller.set
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
                                  child: CameraPreview(controller)),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.mic),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white38,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(Icons.videocam),
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
                    locator<MeetingRepositories>().addParticipant();
                  },
                  child: CustomButton(
                    height: 52,
                    child: Center(
                      child: state.runtimeType == RouterInitial ||
                              state.runtimeType == MeetingInitCompleted
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
