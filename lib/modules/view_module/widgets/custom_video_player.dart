import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:video_player/video_player.dart';
import '../../../services/locator.dart';
import 'package:universal_html/html.dart' as html;

class CustomVideoPlayer extends ConsumerStatefulWidget {
  const CustomVideoPlayer({super.key, required this.src, this.height = 200});
  final String src;
  final double height;
  @override
  ConsumerState<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends ConsumerState<CustomVideoPlayer>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
      html.document.onContextMenu.listen((event) => event.preventDefault());
      controller.play();
      controller.addListener(() async {
        if (controller.value.position == controller.value.duration) {
          await controller.pause();
          await locator<Room>().disconnect();
        }
      });
      if (mounted) {
        setState(() {});
      }
      return;
    }
    controller = locator<VideoPlayerController>();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: VideoPlayer(controller),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
