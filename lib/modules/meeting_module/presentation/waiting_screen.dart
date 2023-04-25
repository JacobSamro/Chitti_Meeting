import 'dart:math';

import 'package:dyte_core/dyte_core.dart';
import 'package:flutter/material.dart';

import '../../../services/locator.dart';
import '../repositories/meeting_repositories.dart';
import 'meeting_screen.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key, required this.name});
  final String name;
  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  late final DyteMobileClient client;
  @override
  void initState() {
    super.initState();
    initMeeting();
  }

  initMeeting() async {
    final String id = Random().nextInt(100).toString();
    client = await locator<MeetingRepositories>().addParticipant(widget.name);
    client.joinRoom();
    Navigator.push(context, MaterialPageRoute(builder: (context)=>MeetingScreen(client: client,)));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("data")));
  }
}
