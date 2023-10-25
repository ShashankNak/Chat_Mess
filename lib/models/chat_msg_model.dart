class MessageModel {
  late String text;
  late String toId;
  late String fromId;
  late String chatImage;
  late Type type;
  late String chatId;
  late String sentTime;
  late Map<String, dynamic> deleteChat;
  late String read;

  MessageModel({
    required this.text,
    required this.toId,
    required this.fromId,
    required this.chatId,
    required this.chatImage,
    required this.type,
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
      chatImage: map["chatImage"] ?? "",
      type: (map["type"] == null) || (map["type"] == Type.text.toString())
          ? Type.text
          : Type.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'toId': toId,
      'fromId': fromId,
      'chatId': chatId,
      'deleteChat': deleteChat,
      'chatImage': chatImage,
      'type': type.toString(),
      'read': read,
      'sentTime': sentTime,
    };
  }
}

enum Type { text, image }
