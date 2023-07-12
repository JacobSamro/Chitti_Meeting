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
        () => VideoPlayerController.networkUrl(Uri.parse(widget.src)),
      );
      controller = locator<VideoPlayerController>();
      await controller.initialize();
      controller.videoPlayerOptions?.allowBackgroundPlayback;
      controller.play();
      // html.document.onContextMenu.listen((event) => event.preventDefault());
      setState(() {});
      return;
    }
    controller = locator<VideoPlayerController>();
    setState(() {});
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
        child: controller.value.isInitialized
            ? SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller))
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
