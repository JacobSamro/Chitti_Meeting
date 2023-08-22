import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_card.dart';
import '../providers/meeting_provider.dart';
import '../states/meeting_states.dart';

class MeetingDialogue extends ConsumerWidget {
  const MeetingDialogue({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final meetingState = ref.read(meetingStateProvider).runtimeType;
    return Scaffold(
      body: Center(
        child: CustomCard(
          iconPath: meetingState == MeetingEnded
              ? 'assets/icons/emoji.png'
              : meetingState == MeetingNotFound
                  ? 'assets/icons/cross_mark.png'
                  : 'assets/icons/call.png',
          content: Text(
            meetingState == MeetingEnded
                ? "Workshop have ended"
                : meetingState == MeetingNotFound
                    ? "Sorry we can't find this meeting"
                    : "You have left the meeting",
            textAlign: TextAlign.center,
            style: textTheme.titleMedium,
          ),
          actions: [
            GestureDetector(
                onTap: () {
                  ref.read(meetingPageProvider.notifier).changePageIndex(0);
                },
                child: CustomButton(
                  width: 178,
                  height: 52,
                  child: Center(
                    child: Text(
                      ref.read(meetingStateProvider).runtimeType ==
                                  MeetingEnded ||
                              ref.read(meetingStateProvider).runtimeType ==
                                  MeetingNotFound
                          ? "Visit paid workshop"
                          : "Rejoin workshop",
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
