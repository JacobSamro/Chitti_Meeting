import 'package:chitti_meeting/common/widgets/payment_card.dart';
import 'package:chitti_meeting/modules/chat_module/models/message_model.dart';
import 'package:chitti_meeting/modules/chat_module/providers/chat_provider.dart';
import 'package:chitti_meeting/modules/meeting_module/states/meeting_states.dart';
import 'package:chitti_meeting/modules/view_module/providers/view_provider.dart';
import 'package:chitti_meeting/services/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late final TextEditingController _controller;
  final FocusNode focusNode = FocusNode();
  late ScrollController scrollController;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    scrollController = ScrollController();
    focusTextField();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
    Future.microtask(
        () => ref.read(unReadMessageProvider.notifier).markAsRead());
  }

  void scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.fastOutSlowIn,
    );
  }

  void focusTextField() {
    if (focusNode.canRequestFocus) {
      focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    focusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    ref.listen(chatProvider, (previous, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });
    final textTheme = Theme.of(context).textTheme;
    final ResponsiveDevice responsiveDevice =
        Responsive().getDeviceType(context);
    final viewType = ref.read(viewProvider).viewType;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black,
          actions: [
            GestureDetector(
              onTap: () {
                if (responsiveDevice == ResponsiveDevice.desktop) {
                  ref.read(viewProvider.notifier).openChatInDesktop(false);
                  return;
                }
                viewType == ViewType.fullScreen
                    ? SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                      ])
                    : null;
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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2.0),
            child: Container(
              color: Colors.white.withOpacity(0.1),
              height: 1.0,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            chat.showPaymentCard ? const PaymentCard() : const SizedBox(),
            Expanded(
                child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                  scrollbars: false,
                  overscroll: false,
                  physics: const BouncingScrollPhysics()),
              child: ListView.builder(
                  itemCount: chat.messages.length,
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    final MessageModel message = chat.messages[index];
                    return Padding(
                      padding: const EdgeInsets.all(7.0),
                      child: Row(
                        mainAxisAlignment: message.by != MessageBy.host
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                              clipBehavior: Clip.hardEdge,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                  color: message.by != MessageBy.host
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(10),
                                    topRight: const Radius.circular(10),
                                    bottomRight: message.by != MessageBy.host
                                        ? const Radius.circular(10)
                                        : Radius.zero,
                                    bottomLeft: message.by != MessageBy.host
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
                                        message.by == MessageBy.local
                                            ? 'You'
                                            : "Host",
                                        style: textTheme.displaySmall?.copyWith(
                                            fontSize: 10,
                                            color: message.by != MessageBy.host
                                                ? Colors.black.withOpacity(0.6)
                                                : Colors.white
                                                    .withOpacity(0.6)),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Text(
                                        DateFormat('h:mm a', Intl.defaultLocale)
                                            .format(
                                                DateTime.parse(message.time)),
                                        style: textTheme.displaySmall?.copyWith(
                                            fontSize: 10,
                                            color: message.by != MessageBy.host
                                                ? Colors.black.withOpacity(0.6)
                                                : Colors.white
                                                    .withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  SizedBox(
                                    width: 220,
                                    child: Text(
                                      message.message,
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                      style: message.by == MessageBy.host
                                          ? textTheme.labelSmall
                                          : textTheme.labelSmall
                                              ?.copyWith(color: Colors.black),
                                    ),
                                  ),
                                ],
                              )),
                        ],
                      ),
                    );
                  }),
            )),
            Container(
              padding: const EdgeInsets.only(left: 16, right: 4),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: RawKeyboardListener(
                      focusNode: FocusNode(),
                      onKey: (RawKeyEvent event) {
                        debugPrint(event.toString());
                        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                          if (_controller.text.isNotEmpty) {
                            ref
                                .read(chatProvider.notifier)
                                .addLocalMessage(_controller.text);
                            _controller.clear();
                          }
                        }
                      },
                      child: TextField(
                        controller: _controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                            hintText: "Type anything...",
                            hintStyle: textTheme.labelSmall?.copyWith(
                                color: Colors.white.withOpacity(0.4)),
                            border: InputBorder.none),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (_controller.text.isNotEmpty) {
                        ref
                            .read(chatProvider.notifier)
                            .addLocalMessage(_controller.text);
                        _controller.clear();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.asset('assets/icons/send.png',
                            width: 20, height: 20),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
