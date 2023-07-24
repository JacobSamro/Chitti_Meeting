import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _CustomVideoPlayerState extends ConsumerState<CustomVideoPlayer> {
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
      controller.setLooping(true);
      controller.addListener(() {
        if (controller.value.hasError) {
          debugPrint(controller.value.errorDescription);
          controller.play();
        }
        if(controller.value.position == controller.value.duration){
          ref.read(meetingStateProvider.notifier).changeState(MeetingEnded());
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: VideoPlayer(controller),
                ),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
