import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../common/widgets/custom_card.dart';

class MeetingDialogue extends ConsumerWidget {
  const MeetingDialogue(
      {required this.iconPath,
      required this.content,
      required this.actions,
      super.key});
  final String iconPath;
  final String content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: CustomCard(
            iconPath: iconPath,
            content: Text(
              content,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium,
            ),
            actions: actions),
      ),
    );
  }
}
