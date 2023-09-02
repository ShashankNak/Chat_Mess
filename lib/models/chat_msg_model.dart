class ChatMessage {
  late String text;
  late String senderId;
  late String senderName;
  late String senderImage;
  late String chatId;
  late String time;
  late bool deleteForMe;
  late bool deleteForEvery;
  late bool isSeen;

  ChatMessage({
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.senderImage,
    required this.chatId,
    required this.time,
    required this.deleteForEvery,
    required this.deleteForMe,
    required this.isSeen,
  });
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      senderImage: map['senderImage'] ?? '',
      chatId: map['chatId'] ?? '',
      deleteForEvery: map['deleteForEvery'] ?? false,
      deleteForMe: map['deleteForMe'] ?? false,
      isSeen: map['isSeen'] ?? false,
      time: map['time'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'senderImage': senderImage,
      'chatId': chatId,
      'deleteForMe': deleteForMe,
      'deleteForEvery': deleteForEvery,
      'isSeen': isSeen,
      'time': time,
    };
  }
}
