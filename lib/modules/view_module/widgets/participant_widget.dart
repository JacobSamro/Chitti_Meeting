import 'package:chitti_meet/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../meeting_module/models/host_model.dart';
import '../../meeting_module/providers/meeting_provider.dart';

class ParticipantWidget extends ConsumerStatefulWidget {
  const ParticipantWidget({super.key, required this.participant});
  final dynamic participant;

  @override
  ConsumerState<ParticipantWidget> createState() => _ParticipantWidgetState();
}

class _ParticipantWidgetState extends ConsumerState<ParticipantWidget> {
  GlobalKey? persistKey;
  bool isAudioMute = true;
  @override
  void initState() {
    super.initState();
    if (!locator.isRegistered<GlobalKey>()) {
      locator.registerLazySingleton<GlobalKey>(() => GlobalKey());
    }
    persistKey = locator<GlobalKey>();
    ref.read(meetingStateProvider.notifier).listenTrack(() {
      if (mounted) {
        setState(() {});
      }
    });
    ref.read(meetingStateProvider.notifier).listener.on<RoomDisconnectedEvent>((p0) async {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    ref.watch(participantProvider);
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: widget.participant is HostModel
            ? persistKey != null
                ? HMSHLSPlayer(
                    hlsUrl: widget.participant.src,
                    key: persistKey!,
                  )
                : const CircularProgressIndicator()
            : widget.participant is HMSPeer
                ? widget.participant.isLocal
                    ? widget.participant.videoTrack != null && widget.participant.videoTrack.isMute == false
                        ? HMSVideoView(
                            track: widget.participant.videoTrack,
                            setMirror: true,
                            scaleType: ScaleType.SCALE_ASPECT_BALANCED,
                          )
                        : ParticipantWithoutVideo(
                            name: widget.participant.name,
                            isMuted: widget.participant.audioTrack != null ? widget.participant.audioTrack.isMute : false,
                          )
                    : widget.participant.videoRemoteTrack != null && widget.participant.videoRemoteTrack.isMute == false
                        ? HMSVideoView(
                            track: widget.participant.videoRemoteTrack,
                            setMirror: true,
                            scaleType: ScaleType.SCALE_ASPECT_BALANCED,
                          )
                        : ParticipantWithoutVideo(
                            name: widget.participant.name,
                            isMuted: widget.participant.audioRemoteTrack != null ? widget.participant.audioRemoteTrack.isMute : false,
                          )
                : (widget.participant.isCameraEnabled() || widget.participant.isScreenShareEnabled()) && widget.participant.videoTracks.first.track != null
                    ? Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: widget.participant.isSpeaking ? Border.all(color: Colors.green) : null),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            children: [
                              VideoTrackRenderer(
                                widget.participant.videoTracks.first.track as VideoTrack,
                                fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                              ),
                              Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.black.withOpacity(0.6),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          widget.participant.name,
                                          style: textTheme.labelSmall?.copyWith(fontSize: 12),
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Image.asset(
                                          widget.participant.isMuted ? 'assets/icons/mic_off.png' : 'assets/icons/mic.png',
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
                        name: widget.participant.name,
                        isMuted: widget.participant.muted,
                      ));
  }
}

class ParticipantWithoutVideo extends StatelessWidget {
  const ParticipantWithoutVideo({
    super.key,
    required this.name,
    required this.isMuted,
  });
  final String name;
  final bool isMuted;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.06),
          // border: participant.isSpeaking
          //     ? Border.all(color: Colors.green)
          //     : null),
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        name,
                        style: textTheme.labelSmall?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Image.asset(
                        isMuted ? 'assets/icons/mic_off.png' : 'assets/icons/mic.png',
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
