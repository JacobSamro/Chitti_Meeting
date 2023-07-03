class MessageModel{
  final MessageBy by;
  final String message;
  final String time = DateTime.now().toString();

  MessageModel(this.by, this.message);

}

enum MessageBy {host,local}