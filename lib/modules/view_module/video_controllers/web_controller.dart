import 'package:video_player/video_player.dart';
import 'dart:html' as html;
import '../../../services/locator.dart';

class WebVideoController {
  Future<VideoPlayerController> intiVideoController(src) async {
    if (!locator.isRegistered<VideoPlayerController>()) {
      locator.registerLazySingleton<VideoPlayerController>(
        () => VideoPlayerController.networkUrl(Uri.parse(src)),
      );
      final controller = locator<VideoPlayerController>();
      await controller.initialize();
      controller.videoPlayerOptions?.allowBackgroundPlayback;
      controller.play();
      controller.setLooping(true);
      html.document.onContextMenu.listen((event) => event.preventDefault());
      return controller;
    }
    return locator<VideoPlayerController>();
  }
}
