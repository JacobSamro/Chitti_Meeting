import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../../services/locator.dart';
// import 'dart:html' as html;

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
        () => VideoPlayerController.networkUrl(Uri.parse(widget.src),
            videoPlayerOptions: VideoPlayerOptions(
                mixWithOthers: true, allowBackgroundPlayback: true)),
      );
      controller = locator<VideoPlayerController>();
      await controller.initialize();
      controller.play();
      controller.addListener(() {
        if (!controller.value.isPlaying) {
          controller.play();
        }
      });
      // html.document.onContextMenu.listen((event) => event.preventDefault());
      setState(() {});
      return;
    }
    controller = locator<VideoPlayerController>();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: controller.value.isInitialized
          ? VideoPlayer(controller)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
