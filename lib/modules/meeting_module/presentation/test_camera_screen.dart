import 'package:camera/camera.dart';
import 'package:chitti_meeting/common/widgets/custom_button.dart';
import 'package:chitti_meeting/common/widgets/custom_inputfield.dart';
import 'package:chitti_meeting/modules/meeting_module/models/workshop_model.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/services/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../providers/meeting_provider.dart';
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
    getWorkshop();
    if (!locator.isRegistered<Room>()) {
      locator.registerLazySingleton<Room>(() => Room());
    }
    if (ref.read(meetingStateProvider.notifier).listener.isDisposed) {
      ref.read(meetingStateProvider.notifier).createListener();
      ref.read(meetingStateProvider.notifier).listen(context);
    }
  }

  void getWorkshop() async {
    await ref
        .read(workshopDetailsProvider.notifier)
        .getWorkshopDetials(widget.hashId);
  }

  Future<void> initCamera() async {
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
    final Workshop workshop = ref.watch(workshopDetailsProvider);
    return Scaffold(
      body: SafeArea(
        child: workshop.meetingId != null && workshop.meetingId!.isNotEmpty
            ? SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: responsiveDevice != ResponsiveDevice.mobile
                            ? 480
                            : 300,
                        height: responsiveDevice != ResponsiveDevice.mobile
                            ? 270
                            : 168,
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
                                    ref
                                        .read(cameraProvider.notifier)
                                        .addCameras();
                                    isVideoOn = true;
                                    initCamera();
                                  },
                                  child: CustomButton(
                                    width: 177,
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                            color:
                                                Colors.black.withOpacity(0.6),
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                              color:
                                                  Colors.black.withOpacity(0.6),
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                const SnackBar(
                                    content: Text("Enter User Name")));
                            return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          await locator<MeetingRepositories>().addParticipant(
                              nameController.text,
                              locator<Room>(),
                              workshop.meetingId!,
                              isVideoOn,
                              ref);
                          isLoading = false;
                          isVideoOn = false;
                        },
                        child: !isLoading
                            ? CustomButton(
                                height:
                                    responsiveDevice != ResponsiveDevice.mobile
                                        ? 68
                                        : 52,
                                width:
                                    responsiveDevice != ResponsiveDevice.mobile
                                        ? 480
                                        : 300,
                                child: Center(
                                    child: Text(
                                  "Join the Workshop",
                                  style: textTheme.titleSmall?.copyWith(
                                    color: Colors.black,
                                  ),
                                )),
                              )
                            : const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                      ),
                    ]),
              )
            : const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
