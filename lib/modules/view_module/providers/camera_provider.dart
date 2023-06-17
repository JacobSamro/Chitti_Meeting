import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraNotifier extends StateNotifier<CameraController> {
  CameraNotifier(super.state);
  bool isVideoOn = false;
  Future<void> addCameras() async {
    if (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      final cameras = await availableCameras();
      state = CameraController(cameras[1], ResolutionPreset.medium);
    } else {
      final cameras = await availableCameras();
      state = CameraController(cameras.length>1?cameras[1]:cameras[0], ResolutionPreset.medium);
    }
  }

  void toggleVideo() {
    isVideoOn = !isVideoOn;
  }
}

final StateNotifierProvider<CameraNotifier, CameraController> cameraProvider =
    StateNotifierProvider<CameraNotifier, CameraController>(
  (ref) => CameraNotifier(
    CameraController(
        const CameraDescription(
            name: "name",
            lensDirection: CameraLensDirection.front,
            sensorOrientation: 0),
        ResolutionPreset.medium),
  ),
);
