import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key, required this.client});
  final DyteMobileClient client;
  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Meeting"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.client.leaveRoom();
          },
          child: const Icon(Icons.call_end),
        ),
        body: StreamBuilder(
            stream: widget.client.activeStream,
            builder: (context, snap) {
              if (snap.hasData) {
                snap.data?.map((e) {
                  return SizedBox(
                    height: 200,
                    child: VideoView(
                      meetingParticipant: e,
                    ),
                  );
                });
              }
              return const Center(child: Text("No data"));
            }));
  }
}
