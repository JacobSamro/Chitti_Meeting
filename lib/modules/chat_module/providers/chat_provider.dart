import 'package:chitti_meeting/common/constants/constants.dart';
import 'package:chitti_meeting/modules/chat_module/models/message_model.dart';
import 'package:chitti_meeting/services/locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatNotifier extends StateNotifier<List<MessageModel>> {
  ChatNotifier(super.state);

  void addLocalMessage(String message) {
    state = [...state, MessageModel(MessageBy.local, message)];
  }

  void addHostMessage(String message) {
    state = [...state, MessageModel(MessageBy.host, message)];
  }

  void listenMessage(String id) async {
    while (true) {
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
          addHostMessage(template['chatTemplate']['message']);
        }
        response?.data = null;
      }
    }
  }
}

final StateNotifierProvider<ChatNotifier, List<MessageModel>> chatProvider =
    StateNotifierProvider<ChatNotifier, List<MessageModel>>(
        (ref) => ChatNotifier([]));
