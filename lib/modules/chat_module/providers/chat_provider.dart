import 'package:chitti_meet/modules/chat_module/models/payment_model.dart';
import 'package:chitti_meet/modules/view_module/providers/view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as sockect;
import '../../../common/constants/api_constants.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatNotifier extends StateNotifier<ChatModel> {
  ChatNotifier(this.ref)
      : super(ChatModel(messages: [], showPaymentCard: false));
  final Ref ref;
  bool _showPaymentCard = false;
  PaymentModel paymentModel = PaymentModel();
  PaymentModel get paymentDetails => paymentModel;
  sockect.Socket? client;
  void addLocalMessage(String message) {
    state = ChatModel(
        messages: [...state.messages, MessageModel(MessageBy.local, message)],
        showPaymentCard: _showPaymentCard);
  }

  void addHostMessage(String message) {
    state = ChatModel(
        messages: [...state.messages, MessageModel(MessageBy.host, message)],
        showPaymentCard: _showPaymentCard);
  }

  void listenMessage(String id) async {
    if (client != null) {
      client!.connect();
    } else {
      client = sockect.io(ApiConstants.messageScoketUrl,
          sockect.OptionBuilder().setTransports(['websocket']).build());
    }
    try {
      client!.onConnect((_) {
        debugPrint('connect');
      });
      client!.on('message', (msg) {
        addHostMessage(msg['text']);
        ref.read(viewProvider).chat
            ? null
            : ref.read(unReadMessageProvider.notifier).addMessageCount();
      });
      client!.onDisconnect((_) => debugPrint('disconnect'));
      client!.on('paymentMessage', (msg) {
        paymentModel = PaymentModel.fromJson(msg);
        _showPaymentCard = true;
        ref.read(viewProvider).chat
            ? null
            : ref.read(unReadMessageProvider.notifier).addMessageCount();
      });
    } catch (e) {
      debugPrint("ERROR in socket connection $e");
    }
  }

  void reset() {
    state = ChatModel(messages: [], showPaymentCard: false);
    client!.disconnect();
  }
}

final StateNotifierProvider<ChatNotifier, ChatModel> chatProvider =
    StateNotifierProvider<ChatNotifier, ChatModel>((ref) => ChatNotifier(ref));

class UnReadMessageNotifier extends StateNotifier<int> {
  UnReadMessageNotifier(super.state);

  void addMessageCount() {
    state = state + 1;
  }

  void markAsRead() {
    state = 0;
  }
}

final StateNotifierProvider<UnReadMessageNotifier, int> unReadMessageProvider =
    StateNotifierProvider<UnReadMessageNotifier, int>(
        (ref) => UnReadMessageNotifier(0));
