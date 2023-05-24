import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/widgets/custom_button.dart';
import '../../../common/widgets/custom_card.dart';
import '../providers/meeting_provider.dart';

class MeetingEndedScreen extends ConsumerWidget {
  const MeetingEndedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            ref.read(meetingPageProvider.notifier).changePageIndex(0);
          },
          child: const CustomCard(
            iconPath: 'assets/icons/call.png',
            content: "You have left the meeting",
            actions: [
              CustomButton(
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
