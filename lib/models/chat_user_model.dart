const String tabelChatUser = 'chat_user';

class ChatUserFields {
  static const String uid = '_uid';
  static const String phoneNumber = 'phoneNumber';
  static const String name = 'name';
  static const String about = 'about';
  static const String image = 'image';
  static const String createdAt = 'createdAt';
  static const String lastActive = 'lastActive';
  static const String isOnline = 'isOnline';
  static const String pushToken = 'pushToken';
}

class ChatUser {
  late String uid;
  late String phoneNumber;
  late String name;
  late String about;
  late String image;
  late String createdAt;
  late String lastActive;
  late bool isOnline;
  late String pushToken;

  ChatUser({
    required this.uid,
    required this.phoneNumber,
    required this.name,
    required this.about,
    required this.image,
    required this.createdAt,
    required this.lastActive,
    required this.isOnline,
    required this.pushToken,
  });

  ChatUser copy({
    String? uid,
    bool? isOnline,
    String? phoneNumber,
    String? name,
    String? about,
    String? image,
    String? createdAt,
    String? lastActive,
    String? pushToken,
  }) =>
      ChatUser(
        uid: uid ?? this.uid,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        name: name ?? this.name,
        about: about ?? this.about,
        image: image ?? this.image,
        createdAt: createdAt ?? this.createdAt,
        lastActive: lastActive ?? this.lastActive,
        isOnline: isOnline ?? this.isOnline,
        pushToken: pushToken ?? this.pushToken,
      );

  factory ChatUser.fromJson(Map<String, Object?> json) => ChatUser(
        uid: json[ChatUserFields.uid].toString(),
        phoneNumber: json[ChatUserFields.phoneNumber].toString(),
        name: json[ChatUserFields.name].toString(),
        about: json[ChatUserFields.about].toString(),
        createdAt: json[ChatUserFields.createdAt].toString(),
        image: json[ChatUserFields.image].toString(),
        isOnline: json[ChatUserFields.isOnline] == 1,
        lastActive: json[ChatUserFields.lastActive].toString(),
        pushToken: json[ChatUserFields.pushToken].toString(),
      );

  //from map
  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      uid: map['uid'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      name: map['name'] ?? '',
      about: map['about'] ?? '',
      createdAt: map['createdAt'] ?? '',
      image: map['image'] ?? '',
      isOnline: map['isOnline'] ?? '',
      lastActive: map['lastActive'] ?? '',
      pushToken: map['pushToken'] ?? '',
    );
  }

  //to map

  Map<String, Object?> toMap() {
    return {
      "uid": uid,
      "phoneNumber": phoneNumber,
      "name": name,
      "image": image,
      "about": about,
      "createdAt": createdAt,
      "lastActive": lastActive,
      "isOnline": isOnline,
      "pushToken": pushToken,
    };
  }

  Map<String, Object?> toJson() => {
        ChatUserFields.uid: uid,
        ChatUserFields.about: about,
        ChatUserFields.name: name,
        ChatUserFields.image: image,
        ChatUserFields.phoneNumber: phoneNumber,
        ChatUserFields.createdAt: createdAt,
        ChatUserFields.isOnline: isOnline ? 1 : 0,
        ChatUserFields.lastActive: lastActive,
        ChatUserFields.pushToken: pushToken,
      };
}
