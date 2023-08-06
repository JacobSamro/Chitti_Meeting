import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
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
  bool isBuffering = true;
  dynamic controller;
  @override
  void initState() {
    super.initState();
    initVideo();
  }

  initVideo() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      if (!locator.isRegistered<VideoController>()) {
        if (!locator.isRegistered<Player>()) {
          locator.registerLazySingleton<Player>(() => Player());
        }
        await locator<Player>().open(Media(widget.src));
        locator.registerLazySingleton<VideoController>(
            () => VideoController(locator<Player>()));
        controller = locator<VideoController>();
        controller?.player.stream.buffer.listen((event) {
          debugPrint('duration :: ${event.inSeconds}');
        });
        controller?.rect.addListener(() {
          if (mounted) {
            setState(() {});
          }
        });

        return;
      }
      try {
        controller = locator<VideoController>();
      } catch (e) {
        throw Exception(e);
      }
    } else {
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
    debugPrint('controller :: ${controller.runtimeType}');
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return controller != null
        ? controller is VideoController
            ? controller!.player.state.buffering == false
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Video(
                        controller: controller!,
                        fit: BoxFit.fitWidth,
                        controls: (state) => const SizedBox(),
                      ),
                    ),
                  )
                : const Center(child: CircularProgressIndicator())
            : controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: VideoPlayer(controller),
                    ))
                : const Center(child: CircularProgressIndicator())
        : const Center(child: CircularProgressIndicator());
  }
}
