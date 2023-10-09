import 'dart:math';
import 'package:chitti_meet/services/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_js/video_js.dart';
import '../../../services/locator.dart';
// import 'package:universal_html/html.dart' as html;
import 'package:video_js/src/video_js_widget.dart';

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
  dynamic controller;
  @override
  void initState() {
    super.initState();
    initVideo();
  }

  void initVideo() async {
    if (!kIsWeb) {
      if (!locator.isRegistered<VideoController>()) {
        if (!locator.isRegistered<Player>()) {
          locator.registerLazySingleton<Player>(() => Player());
        }
        await locator<Player>().open(Media(widget.src));
        locator.registerLazySingleton<VideoController>(
            () => VideoController(locator<Player>()));
        controller = locator<VideoController>();
        controller?.player.stream.buffering.listen((event) {
          debugPrint(event.toString());
          // if (!event) {
          if (mounted) {
            controller?.player.play();
            setState(() {});
          }
          // }
        });
        controller?.player.stream.duration.listen((event) {
          if (mounted) {
            controller?.player.play();
            // setState(() {});
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
      final intValue = Random().nextInt(10);
      if (locator.isRegistered<VideoJsController>()) {
        controller = locator<VideoJsController>();
        controller.setSRC(widget.src, type: 'application/x-mpegURL');
        controller.play();
      }
      if (!locator.isRegistered<VideoJsController>()) {
        locator.registerLazySingleton<VideoJsController>(
          () => VideoJsController(
            "videoHost",
            videoJsOptions: VideoJsOptions(
                controls: false,
                loop: false,
                muted: false,
                aspectRatio: '16:9',
                fluid: false,
                language: 'en',
                liveui: false,
                notSupportedMessage:
                    'The Stream is not available at the moment',
                playbackRates: [1, 2, 3],
                preferFullWindow: false,
                responsive: false,
                sources: [Source(widget.src, 'application/x-mpegURL')],
                suppressNotSupportedError: false),
          ),
        );
        controller = locator<VideoJsController>();
        controller.init();
      }
      try {
        debugPrint(intValue.toString());

        VideoJsResults().listenToValueFromJs('videoHost', 'onReady', (ready) {
          debugPrint('onReady: $ready');
          ready == 'true' ? locator<VideoJsController>().play() : null;
          // final videoElement =
          //     html.document.getElementById('video$intValue_html5_api');
          // videoElement?.setAttribute('disablepictureinpicture', '');
          // videoElement?.on['enterpictureinpicture'].listen((event) {
          //   debugPrint('Attempting to enter PiP mode');
          //   event.preventDefault();
          // });
        });
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    super.build(context);
    return AbsorbPointer(
        child: controller != null
            ? controller is VideoController
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Video(
                      fit: responsiveDevice == ResponsiveDevice.desktop
                          ? BoxFit.cover
                          : BoxFit.contain,
                      controls: (state) => controller.player.state.buffering
                          ? const Center(
                              child: CircularProgressIndicator(
                              color: Colors.white,
                            ))
                          : const SizedBox(),
                      controller: controller,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return VideoJsWidget(
                          videoJsController: controller,
                          height: double.infinity,
                          width: double.infinity,
                        );
                      },
                    ),
                  )
            : const Center(
                child: CircularProgressIndicator(
                color: Colors.white,
              )));
  }
}
