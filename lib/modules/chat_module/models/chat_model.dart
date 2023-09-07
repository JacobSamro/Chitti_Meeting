import 'message_model.dart';

class ChatModel {
  final List<MessageModel> messages;
  final bool showPaymentCard;

  ChatModel({required this.messages, required this.showPaymentCard});
}
