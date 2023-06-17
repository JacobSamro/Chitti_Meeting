import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({super.key, required this.src, this.height = 200});
  final String src;
  final double height;
  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  late VideoPlayerController controller;
  @override
  void initState() {
    super.initState();
    initVideo();
  }

  initVideo() async {
    if (!locator.isRegistered<VideoPlayerController>()) {
      locator.registerLazySingleton<VideoPlayerController>(
        () => VideoPlayerController.network(widget.src),
      );
      controller = locator<VideoPlayerController>();
      await controller.initialize();
      controller.videoPlayerOptions?.allowBackgroundPlayback;
      controller.play();
      controller.setLooping(true);
      setState(() {});
      return;
    }
    controller = locator<VideoPlayerController>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.fill,
          // height: widget.height,
          // width: double.infinity,
          child: controller.value.isInitialized
              ? SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller))
              : const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
