import 'package:camera/camera.dart';
import 'package:chitti_meeting/modules/view_module/providers/camera_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocalUser extends ConsumerStatefulWidget {
  const LocalUser({super.key});

  @override
  ConsumerState<LocalUser> createState() => _LocalUserState();
}

class _LocalUserState extends ConsumerState<LocalUser> {
  late CameraController controller;
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    controller = ref.read(cameraProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return controller.value.isInitialized
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: CameraPreview(controller),
            ),
          )
        : const SizedBox();
  }
}
