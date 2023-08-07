import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_card.dart';
import '../providers/meeting_provider.dart';

class MeetingDialogue extends ConsumerWidget {
  const MeetingDialogue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MeetingStates state = ref.watch(meetingStateProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: CustomCard(
          iconPath: state.runtimeType == MeetingEnded
              ? 'assets/icons/emoji.png'
              : 'assets/icons/call.png',
          content: Text(
            state.runtimeType == MeetingEnded
                ? "Workshop have ended"
                : "You have left the meeting",
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          actions: [
            GestureDetector(
              onTap: () {
                ref.read(meetingPageProvider.notifier).changePageIndex(0);
              },
              child: state.runtimeType == MeetingEnded
                  ? const CustomButton(
                      width: 178,
                      height: 52,
                      child: Center(
                        child: Text(
                          "Visit paid workshop",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    )
                  : const CustomButton(
                      width: 178,
                      height: 52,
                      child: Center(
                        child: Text(
                          "Rejoin workshop",
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
    );
  }
}
