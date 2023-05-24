import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        actions: [TextButton(onPressed: () {}, child: const Text('X'))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Expanded(
              child: ListView.builder(
                  itemCount: 8,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Row(
                        mainAxisAlignment: index % 2 != 0
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                              clipBehavior: Clip.hardEdge,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                  color: index % 2 != 0
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(10),
                                    topRight: const Radius.circular(10),
                                    bottomRight: index % 2 == 0
                                        ? const Radius.circular(10)
                                        : Radius.zero,
                                    bottomLeft: index % 2 != 0
                                        ? const Radius.circular(10)
                                        : Radius.zero,
                                  )),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Participant",
                                        style: textTheme.displaySmall?.copyWith(
                                            fontSize: 10,
                                            color: index % 2 != 0
                                                ? Colors.black.withOpacity(0.6)
                                                : Colors.white
                                                    .withOpacity(0.6)),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        "4:30 PM",
                                        style: textTheme.displaySmall?.copyWith(
                                            fontSize: 10,
                                            color: index % 2 != 0
                                                ? Colors.black.withOpacity(0.6)
                                                : Colors.white
                                                    .withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    "Hello",
                                    style: index % 2 == 0
                                        ? textTheme.labelSmall
                                        : textTheme.labelSmall
                                            ?.copyWith(color: Colors.black),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    );
                  })),
          Container(
            width: double.infinity,
            height: 48,
            padding: const EdgeInsets.only(left: 16, right: 4),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14)),
            child: TextField(
              decoration: InputDecoration(
                  hintText: "Type anything...",
                  hintStyle: textTheme.labelSmall
                      ?.copyWith(color: Colors.white.withOpacity(0.4)),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  border: InputBorder.none),
            ),
          )
        ]),
      ),
    );
  }
}
