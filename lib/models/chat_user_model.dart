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

  Map<String, dynamic> toMap() {
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
}
