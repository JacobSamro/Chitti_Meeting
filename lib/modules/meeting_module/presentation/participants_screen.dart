import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';

import '../../../services/locator.dart';

class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DyteMobileClient client = locator<DyteMobileClient>();
    final textTheme = Theme.of(context).textTheme;
    // final length = client.activeStream.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [TextButton(onPressed: () {}, child: const Text('X'))],
      ),
      body: StreamBuilder(
          stream: client.activeStream,
          builder: (context, snap) {
            if (snap.hasData) {
              final participants = snap.data;
              return ListView.builder(
                  itemCount: participants?.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                            participants![index].name,
                            style: textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.75)),
                          ),
                        ],
                      ),
                    );
                  });
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }),
    );
  }
}
