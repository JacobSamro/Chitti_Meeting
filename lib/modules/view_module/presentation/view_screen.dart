import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../services/locator.dart';
import '../../../services/responsive.dart';
import '../../chat_module/presentation/chat_screen.dart';
import '../../meeting_module/presentation/participants_screen.dart';
import '../../meeting_module/providers/meeting_provider.dart';
import '../../meeting_module/repositories/meeting_respositories.dart';
import '../../meeting_module/states/meeting_states.dart';
import '../models/view_state.dart';
import '../providers/view_provider.dart';
import '../widgets/participant_widget.dart';
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
    ref.read(meetingStateProvider.notifier).sortOrder(() {
      if (mounted) {
        setState(() {});
      }
    });
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
        ? responsiveDevice != ResponsiveDevice.desktop ||
                viewType == ViewType.gallery
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
                            return participantTracks.length <= 1 &&
                                    responsiveDevice == ResponsiveDevice.mobile
                                ? SizedBox(
                                    height: 300,
                                    width: MediaQuery.of(context).size.width,
                                    child: ParticipantWidget(
                                      participant: e,
                                    ),
                                  )
                                : Expanded(
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
                                  crossAxisCount: responsiveDevice !=
                                          ResponsiveDevice.mobile
                                      ? participantTracks.length <= 4
                                          ? 2
                                          : 3
                                      : 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: responsiveDevice !=
                                          ResponsiveDevice.mobile
                                      ? MediaQuery.of(context).size.height / 2.5
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
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Container(
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
                                                : const SizedBox()),
                                  )
                                : const SizedBox(),
                          ],
                        );
                })
            : Row(children: [
                Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: double.infinity,
                      child: ParticipantWidget(
                        participant: participants[0],
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: viewState.chat || viewState.participants
                        ? 450
                        : viewType != ViewType.speaker
                            ? 250
                            : 0,
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
                            : viewType != ViewType.speaker
                                ? ListView(
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
                                  )
                                : const SizedBox(),
                  ),
                )
              ])
        : const Center(
            child: CircularProgressIndicator(
            color: Colors.white,
          ));
  }
}
