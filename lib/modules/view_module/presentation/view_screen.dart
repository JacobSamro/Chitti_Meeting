import 'package:chitti_meeting/modules/chat_module/presentation/chat_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/participants_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:chitti_meeting/modules/view_module/models/view_state.dart';
import 'package:chitti_meeting/modules/view_module/widgets/custom_video_player.dart';
import 'package:chitti_meeting/modules/view_module/widgets/participant_widget.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/services/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../providers/view_provider.dart';
// import '../widgets/page_number.dart';

class ViewScreen extends ConsumerStatefulWidget {
  const ViewScreen({super.key});

  @override
  ConsumerState<ViewScreen> createState() => _ViewScreenState();
}

class _ViewScreenState extends ConsumerState<ViewScreen> {
  late final PageController _pageController;
  final Room room = locator<Room>();
  final MeetingRepositories meetingRepositories =
      locator<MeetingRepositories>();
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    ref.watch(participantProvider);
    final ViewState viewState = ref.watch(viewProvider);
    final ViewType viewType = viewState.viewType;
    final List<dynamic> participants = meetingRepositories.sortParticipant(
        responsiveDevice == ResponsiveDevice.desktop &&
                viewType == ViewType.standard
            ? ViewType.speaker
            : viewType,
        ref);
    return participants.isNotEmpty
        ? viewType == ViewType.speaker
            ? SizedBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                child: const CustomVideoPlayer(
                    src:
                        "https://streameggs.net/0ae71bda-4d2f-4961-9ced-e6d21ede69e6/master.m3u8"),
              )
            : responsiveDevice != ResponsiveDevice.desktop
                ? PageView.builder(
                    padEnds: false,
                    controller: _pageController,
                    itemCount: participants.length,
                    itemBuilder: (context, index) {
                      final participantTracks = viewType != ViewType.speaker
                          ? participants[index] as List<dynamic>
                          : participants;
                      return viewType == ViewType.standard
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: participantTracks.map((e) {
                                return Expanded(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ParticipantWidget(
                                      participant: e,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      mainAxisExtent: responsiveDevice !=
                                              ResponsiveDevice.mobile
                                          ? MediaQuery.of(context).size.height /
                                              2.5
                                          : null,
                                    ),
                                    itemCount: participantTracks.length,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                        height: 200,
                                        child: ParticipantWidget(
                                          participant: participantTracks[index],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                responsiveDevice == ResponsiveDevice.desktop &&
                                            viewState.chat ||
                                        viewState.participants
                                    ? Container(
                                        width: 450,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                                style: BorderStyle.solid,
                                                width: 1)),
                                        child: viewState.chat
                                            ? const ChatScreen()
                                            : viewState.participants
                                                ? const ParticipantsScreen()
                                                : const SizedBox())
                                    : const SizedBox(),
                              ],
                            );
                    })
                : Row(children: [
                    Expanded(
                        flex: 2,
                        child: ParticipantWidget(
                          participant: participants[0],
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        width: viewState.chat || viewState.participants
                            ? 450
                            : 250,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                style: BorderStyle.solid,
                                width: 1)),
                        child: viewState.chat
                            ? const ChatScreen()
                            : viewState.participants
                                ? const ParticipantsScreen()
                                : ListView(
                                    children: participants.sublist(1).map((e) {
                                      return Container(
                                          height: 200,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: ParticipantWidget(
                                            participant: e,
                                          ));
                                    }).toList(),
                                  ),
                      ),
                    )
                  ])
        : const Center(
            child: CircularProgressIndicator(
            color: Colors.white,
          ));
  }
}

class ParticipantWithoutVideo extends StatelessWidget {
  const ParticipantWithoutVideo({
    super.key,
    required this.participantName,
  });
  final String participantName;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white.withOpacity(0.06),
        ),
        child: Stack(
          children: [
            Center(
                child: Image.asset(
              'assets/icons/user_rounded.png',
              width: 44,
              height: 44,
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
                        participantName,
                        style: textTheme.labelSmall?.copyWith(fontSize: 12),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Image.asset(
                        'assets/icons/mic_off.png',
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
