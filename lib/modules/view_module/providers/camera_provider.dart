import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraNotifier extends StateNotifier<CameraController> {
  CameraNotifier(super.state);
  bool isVideoOn = false;
  Future<void> addCameras() async {
    try {
      final cameras = await availableCameras();
      state = CameraController(
          cameras.length > 1 ? cameras[1] : cameras[0],
          enableAudio: false,
          ResolutionPreset.medium);
    } catch (e) {
      if (e is CameraException && e.code == 'CameraAccessDenied') {
        debugPrint("Camera access denied");
      }
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
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0),
        ResolutionPreset.medium,
        enableAudio: false),
  ),
);
