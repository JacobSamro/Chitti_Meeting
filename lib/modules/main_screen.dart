
import 'package:chitti_meeting/modules/meeting_module/presentation/meeting_screen.dart';
import 'package:chitti_meeting/modules/meeting_module/presentation/waiting_screen.dart';

import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late TextEditingController _name;
  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chitti Meeting"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(label: Text("Name")),
          ),
          ElevatedButton(
              onPressed: () {
                // final String id = Random().nextInt(100).toString();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => WaitingScreen(name: _name.text)));
              },
              child: const Text("Join"))
        ],
      ),
    );
  }
}
