class MessageModel {
  late String text;
  late String toId;
  late String fromId;
  late String chatId;
  late String sentTime;
  late bool deleteForMe;
  late bool deleteForYou;
  late String read;

  MessageModel({
    required this.text,
    required this.toId,
    required this.fromId,
    required this.chatId,
    required this.sentTime,
    required this.deleteForYou,
    required this.deleteForMe,
    required this.read,
  });
  factory MessageModel.fromJson(Map<String, dynamic> map) {
    return MessageModel(
      text: map['text'] ?? '',
      toId: map['toId'] ?? '',
      fromId: map['fromId'] ?? '',
      chatId: map['chatId'] ?? '',
      deleteForYou: map['deleteForYou'] ?? false,
      deleteForMe: map['deleteForMe'] ?? false,
      read: map['read'] ?? false,
      sentTime: map['sentTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'toId': toId,
      'fromId': fromId,
      'chatId': chatId,
      'deleteForMe': deleteForMe,
      'deleteForEvery': deleteForYou,
      'read': read,
      'sentTime': sentTime,
    };
  }
}
