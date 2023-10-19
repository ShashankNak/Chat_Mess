class GroupMessageModel {
  late String text;
  late String groupId;
  late String fromId;
  late String chatId;
  late String sentTime;
  late Map<String, dynamic> deleteChat;
  late String read;

  GroupMessageModel({
    required this.text,
    required this.groupId,
    required this.fromId,
    required this.chatId,
    required this.sentTime,
    required this.deleteChat,
    required this.read,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> map) {
    return GroupMessageModel(
      text: map['text'] ?? "",
      groupId: map['groupId'] ?? "",
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
      'groupId': groupId,
      'fromId': fromId,
      'chatId': chatId,
      'deleteChat': deleteChat,
      'read': read,
      'sentTime': sentTime,
    };
  }
}
