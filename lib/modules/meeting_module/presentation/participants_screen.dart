import 'package:chitti_meeting/modules/meeting_module/providers/meeting_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ParticipantsScreen extends ConsumerWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final participants = ref.watch(participantProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Participants'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          actions: [TextButton(onPressed: () {}, child: const Text('X'))],
        ),
        body: ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              // final participant = participants[index] as Participant;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(50)),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Text(
                      participants[index].name == '' ||
                              participants[index].name == null
                          ? participants[index].identity
                          : participants[index].name,
                      style: textTheme.labelSmall
                          ?.copyWith(color: Colors.white.withOpacity(0.75)),
                    ),
                  ],
                ),
              );
            }));
  }
}
