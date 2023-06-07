import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

import '../../meeting_module/models/host_model.dart';
import '../presentation/view_screen.dart';
import 'custom_video_player.dart';
import 'local_user.dart';

class ParticipantWidget extends StatelessWidget {
  const ParticipantWidget({super.key, required this.participant});
  final dynamic participant;
  @override
  Widget build(BuildContext context) {
    return participant is HostModel
        // ? const SizedBox(
        //     height: 200,
        //   )
        ? CustomVideoPlayer(src: participant.src)
        : participant is Participant
            ? participant.isCameraEnabled()
                ? SizedBox(
                    height: 200,
                    child: VideoTrackRenderer(
                      participant.videoTracks.first.track as VideoTrack,
                      fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  )
                : ParticipantWithoutVideo(
                    participantName: participant.identity,
                  )
            : const LocalUser();
  }
}
