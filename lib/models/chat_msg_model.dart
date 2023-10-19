class MessageModel {
  late String text;
  late String toId;
  late String fromId;
  late String chatId;
  late String sentTime;
  late Map<String, dynamic> deleteChat;
  late String read;

  MessageModel({
    required this.text,
    required this.toId,
    required this.fromId,
    required this.chatId,
    required this.sentTime,
    required this.deleteChat,
    required this.read,
  });

  factory MessageModel.fromJson(Map<String, dynamic> map) {
    return MessageModel(
      text: map['text'] ?? "",
      toId: map['toId'] ?? "",
      fromId: map['fromId'] ?? "",
      chatId: map['chatId'] ?? "",
      deleteChat: map['deleteChat'] ?? {},
      read: map['read'] ?? "",
      sentTime: map['sentTime'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'toId': toId,
      'fromId': fromId,
      'chatId': chatId,
      'deleteChat': deleteChat,
      'read': read,
      'sentTime': sentTime,
    };
  }
}
