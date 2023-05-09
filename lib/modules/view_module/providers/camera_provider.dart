import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraNotifier extends StateNotifier<List<CameraDescription>>{
  CameraNotifier(super.state);
  addCameras() async {
    final cameras = await availableCameras();
    state = cameras;
  }
}

final StateNotifierProvider<CameraNotifier, List<CameraDescription>> cameraProvider = StateNotifierProvider<CameraNotifier, List<CameraDescription>>((ref) => CameraNotifier([]));