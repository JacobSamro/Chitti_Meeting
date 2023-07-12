import 'package:video_player/video_player.dart';
import '../../../services/locator.dart';

class MobileVideoController{
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
      return controller;
    }
    return locator<VideoPlayerController>();
  }
}