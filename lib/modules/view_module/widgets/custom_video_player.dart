import 'package:chitti_meeting/modules/view_module/video_controllers/mobile_controller.dart';
import 'package:chitti_meeting/modules/view_module/video_controllers/web_controller.dart';
import 'package:flutter/foundation.dart';
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
    if (kIsWeb) {
      controller = await WebVideoController().intiVideoController(widget.src);
      setState(() {});
      return;
    }
    controller = await MobileVideoController().intiVideoController(widget.src);
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
