import 'package:chitti_meeting/common/constants/constants.dart';
import 'package:chitti_meeting/modules/chat_module/models/chat_model.dart';
import 'package:chitti_meeting/modules/chat_module/models/message_model.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatNotifier extends StateNotifier<ChatModel> {
  ChatNotifier(this.ref)
      : super(ChatModel(messages: [], showPaymentCard: false));
  final Ref ref;
  bool canListenMessge = false;
  bool _showPaymentCard = false;
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

  void canListen(bool value) {
    canListenMessge = value;
  }

  void listenMessage(String id) async {
    while (canListenMessge) {
      Response? response;
      try {
        response =
            await locator<Dio>().get('${ApiConstants.hostMessageUrl}$id');
        await Future.delayed(const Duration(seconds: 1));
      } catch (onError) {
        debugPrint(onError.toString());
        response = null;
      }
      if (response?.data != null) {
        for (var template in response?.data) {
          template['chatTemplate']['type'] == 'payment_message'
              ? _showPaymentCard = true
              : null;
          addHostMessage(template['chatTemplate']['message']);
          ref.read(unReadMessageProvider.notifier).addMessageCount();
        }
        response?.data = null;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void reset() {
    state = ChatModel(messages: [], showPaymentCard: false);
    canListenMessge = false;
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
