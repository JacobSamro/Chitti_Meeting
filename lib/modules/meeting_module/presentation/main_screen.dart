import 'package:chitti_meeting/modules/chat_module/providers/chat_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/models/workshop_model.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:chitti_meeting/modules/view_module/providers/view_provider.dart';
import 'package:chitti_meeting/modules/view_module/widgets/custom_video_player.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:chitti_meeting/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:livekit_client/livekit_client.dart';
import '../../../common/widgets/custom_timer.dart';
import '../../../services/responsive.dart';
import '../../view_module/models/view_state.dart';
import '../../view_module/presentation/view_screen.dart';
import '../providers/meeting_provider.dart';
import '../widgets/navigationbar.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final Room room = locator<Room>();
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(participantProvider.notifier).addLocalParticipantTrack();
      ref
          .read(chatProvider.notifier)
          .listenMessage(ref.read(workshopDetailsProvider.notifier).hashId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    ref.invalidate(participantProvider);
    room.dispose();
    locator.unregister<Room>();
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
                          Utils.openFloatingNavigationBar(context);
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: CustomVideoPlayer(
                              height: double.infinity,
                              src:
                                  ref.read(workshopDetailsProvider).sourceUrl!),
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: CustomVideoPlayer(
                                  src: ref
                                      .read(workshopDetailsProvider)
                                      .sourceUrl!),
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
