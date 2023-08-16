import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';
import '../../meeting_module/models/host_model.dart';
import '../../meeting_module/providers/meeting_provider.dart';
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
    // widget.participant is LocalParticipant
    //     ? debugPrint(widget.participant.videoTracks.first.track.toString())
    //     : null;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: widget.participant is HostModel
            ? CustomVideoPlayer(
                src: widget.participant.src,
              )
            : widget.participant is Participant
                ? (widget.participant.isCameraEnabled() ||
                            widget.participant.isScreenShareEnabled()) &&
                        widget.participant.videoTracks.first.track != null
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: widget.participant.isSpeaking
                                ? Border.all(color: Colors.green)
                                : null),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              VideoTrackRenderer(
                                widget.participant.videoTracks.first.track
                                    as VideoTrack,
                                mirrorMode: VideoViewMirrorMode.mirror,
                                fit: rtc.RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitCover,
                              ),
                              Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.participant.name,
                                          style: textTheme.labelSmall
                                              ?.copyWith(fontSize: 12),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Image.asset(
                                          widget.participant.isMuted
                                              ? 'assets/icons/mic_off.png'
                                              : 'assets/icons/mic.png',
                                          width: 16,
                                          height: 16,
                                        )
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      )
                    : ParticipantWithoutVideo(
                        participant: widget.participant,
                      )
                : const LocalUser());
  }
}

class ParticipantWithoutVideo extends StatelessWidget {
  const ParticipantWithoutVideo({
    super.key,
    required this.participant,
  });
  final Participant participant;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.white.withOpacity(0.06),
            border: participant.isSpeaking
                ? Border.all(color: Colors.green)
                : null),
        child: Stack(
          children: [
            Center(
                child: Image.asset(
              'assets/icons/user_rounded.png',
              width: 60,
              height: 60,
            )),
            Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        participant.name,
                        style: textTheme.labelSmall?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Image.asset(
                        participant.isMuted
                            ? 'assets/icons/mic_off.png'
                            : 'assets/icons/mic.png',
                        width: 16,
                        height: 16,
                      )
                    ],
                  ),
                ))
          ],
        ));
  }
}
