import '../../../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../common/widgets/custom_timer.dart';
import '../../../services/locator.dart';
import '../../../services/responsive.dart';
import '../../chat_module/providers/chat_provider.dart';
import '../../view_module/models/view_state.dart';
import '../../view_module/presentation/view_screen.dart';
import '../../view_module/providers/view_provider.dart';
import '../../view_module/widgets/participant_widget.dart';
import '../models/workshop_model.dart';
import '../providers/meeting_provider.dart';
import '../repositories/meeting_respositories.dart';
import '../states/meeting_states.dart';
import '../widgets/navigationbar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final Room room = locator<Room>();
  final MeetingRepositories meetingRepositories =
      locator<MeetingRepositories>();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final MeetingSDK sdk = ref.read(meetingSDKProvider).meetingSDK;
      if (sdk == MeetingSDK.livekit) {
        await ref.read(participantProvider.notifier).addLocalParticipantTrack();
      }
      ref
          .read(chatProvider.notifier)
          .listenMessage(ref.read(workshopDetailsProvider.notifier).hashId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    // ref.invalidate(participantProvider);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final ViewState viewState = ref.watch(viewProvider);
    final ViewType viewType = viewState.viewType;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    final Workshop workshop = ref.read(workshopDetailsProvider);
    return SafeArea(
      child: Scaffold(
        appBar: viewType != ViewType.fullScreen &&
                responsiveDevice != ResponsiveDevice.desktop
            ? AppBar(
                title: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          workshop.workshopName.toString(),
                          style: textTheme.bodySmall
                              ?.copyWith(color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      const CustomTimer()
                    ],
                  ),
                ),
              )
            : null,
        body: viewType != ViewType.fullScreen
            ? const Column(
                children: [
                  Flexible(flex: 1, child: ViewScreen()),
                  CustomNavigationBar()
                ],
              )
            : SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: responsiveDevice != ResponsiveDevice.desktop
                    ? GestureDetector(
                        onTap: () {
                          context.openFloatingNavigationBar(true);
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: ParticipantWidget(
                              participant: meetingRepositories
                                  .sortParticipant(viewType, ref)
                                  .first),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: ParticipantWidget(
                                  participant: meetingRepositories
                                      .sortParticipant(viewType, ref)
                                      .first),
                            ),
                          ),
                          const CustomNavigationBar()
                        ],
                      ),
              ),
      ),
    );
  }
}
