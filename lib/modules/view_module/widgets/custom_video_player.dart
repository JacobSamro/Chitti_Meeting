import 'package:chewie/chewie.dart';
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
        // controller?.player.stream.buffer.listen((event) {
        //   debugPrint('duration :: ${event.inSeconds}');
        // });
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
        await locator<VideoPlayerController>().initialize();
      }
      if (!locator.isRegistered<ChewieController>()) {
        controller = ChewieController(
            // aspectRatio: 16 / 9,
            videoPlayerController: locator<VideoPlayerController>(),
            autoPlay: true,
            showControls: false);
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
      controller = locator<ChewieController>();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AbsorbPointer(
      child: controller != null
          ? controller is VideoController
              ? controller!.player.state.buffering == false
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Video(
                          controller: controller!,
                        ),
                      ),
                    )
                  : const Center(child: CircularProgressIndicator())
              : controller.videoPlayerController.value.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: Chewie(controller: controller),
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(child: CircularProgressIndicator())
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
