class GroupMessageModel {
  late String text;
  late String groupId;
  late String fromId;
  late String sentTime;
  late String chatImage;
  late TypeG type;
  late Map<String, dynamic> deleteChat;

  GroupMessageModel({
    required this.text,
    required this.groupId,
    required this.fromId,
    required this.sentTime,
    required this.chatImage,
    required this.type,
    required this.deleteChat,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> map) {
    return GroupMessageModel(
      text: map['text'] ?? "",
      groupId: map['groupId'] ?? "",
      fromId: map['fromId'] ?? "",
      deleteChat: map['deleteChat'] ?? {},
      sentTime: map['sentTime'] ?? "",
      chatImage: map["chatImage"] ?? "",
      type: (map["type"] == null) || (map["type"] == TypeG.text.toString())
          ? TypeG.text
          : TypeG.image,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'groupId': groupId,
      'fromId': fromId,
      'deleteChat': deleteChat,
      'sentTime': sentTime,
      'chatImage': chatImage,
      'type': type.toString(),
    };
  }
}

enum TypeG { text, image }
