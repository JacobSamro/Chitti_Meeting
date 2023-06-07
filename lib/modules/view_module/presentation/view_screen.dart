import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/repositories/meeting_respositories.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:chitti_meeting/modules/view_module/widgets/participant_widget.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';

import '../providers/view_provider.dart';
import '../widgets/page_number.dart';

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
    ref.watch(participantProvider);
    final ViewType viewType = ref.watch(viewProvider);
    final List<dynamic> participants =
        meetingRepositories.sortParticipant(viewType, ref);
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        participants.isNotEmpty
            ? Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: participants.length,
                  itemBuilder: (context, index) {
                    final participantsTrack = viewType != ViewType.speaker
                        ? participants[index] as List<dynamic>
                        : participants;
                    return viewType == ViewType.speaker
                        ? ParticipantWidget(participant: participantsTrack)
                        : viewType != ViewType.standard
                            ? Center(
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20),
                                  itemBuilder: (context, index) =>
                                      ParticipantWidget(
                                          participant:
                                              participantsTrack[index]),
                                  itemCount: participantsTrack.length,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: participantsTrack
                                    .map((dynamic participant) =>
                                        ParticipantWidget(
                                            participant: participant))
                                    .toList(),
                              );
                  },
                ),
              )
            : const Expanded(child: CircularProgressIndicator()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                        duration: const Duration(milliseconds: 1),
                        curve: Curves.ease);
                  },
                  child: Image.asset(
                    'assets/icons/arrow_left.png',
                    width: 24,
                    height: 24,
                  ),
                ),
                PageNumber(pageController: _pageController),
                GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                        duration: const Duration(milliseconds: 1),
                        curve: Curves.ease);
                  },
                  child: Image.asset(
                    'assets/icons/arrow_right.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        )
      ],
    );
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
    return Container(
        // padding: const EdgeInsets.all(15),
        width: double.infinity,
        height: 200,
        color: Colors.white.withOpacity(0.06),
        child: Stack(
          children: [
            Center(
                child: Image.asset(
              'assets/icons/user_rounded.png',
              width: 44,
              height: 44,
            )),
            Positioned(bottom: 10, right: 10, child: Text(participantName))
          ],
        ));
  }
}
