import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
// import '../../../services/responsive.dart';
import '../../meeting_module/models/host_model.dart';
import '../../meeting_module/providers/meeting_provider.dart';
import '../presentation/view_screen.dart';
import 'custom_video_player.dart';
import 'local_user.dart';

class ParticipantWidget extends ConsumerStatefulWidget {
  const ParticipantWidget({super.key, required this.participant});
  final dynamic participant;

  @override
  ConsumerState<ParticipantWidget> createState() => _ParticipantWidgetState();
}

class _ParticipantWidgetState extends ConsumerState<ParticipantWidget> {
  @override
  void initState() {
    super.initState();
    ref.read(meetingStateProvider.notifier).listenTrack(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // final ResponsiveDevice responsiveDevice =
    //     Responsive().getDeviceType(context);
    return widget.participant is HostModel
        // ? const SizedBox(
        //     height: 200,
        //   )
        ? CustomVideoPlayer(src: widget.participant.src,)
        : widget.participant is Participant
            ? widget.participant.isCameraEnabled() &&
                    widget.participant.videoTracks.first.track != null
                ? SizedBox(
                    height: 200,
                    child: VideoTrackRenderer(
                      widget.participant.videoTracks.first.track as VideoTrack,
                      fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  )
                : ParticipantWithoutVideo(
                    participantName: widget.participant.identity,
                  )
            : const LocalUser();
  }
}
