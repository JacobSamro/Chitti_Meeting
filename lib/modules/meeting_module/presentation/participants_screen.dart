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
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Image.asset(
                  'assets/icons/cancel.png',
                  width: 12,
                  height: 12,
                ),
              ),
            )
          ],
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
                    CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withOpacity(0.08),
                        child: Image.asset(
                          'assets/icons/user.png',
                          width: 20,
                          height: 20,
                        )),
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
