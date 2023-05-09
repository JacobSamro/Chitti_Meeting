import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideoPlayer extends StatefulWidget {
  const CustomVideoPlayer({super.key, required this.src});
  final String src;

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
          () => VideoPlayerController.network(widget.src));
      controller = locator<VideoPlayerController>();
      await controller.initialize();
      controller.play();
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
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: controller.value.isInitialized
          ? VideoPlayer(controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
