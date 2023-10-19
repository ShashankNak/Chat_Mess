class GroupModel {
  final List<String> admins;
  final List<String> users;
  final String id;
  final String name;
  final String about;
  final String image;
  final String createdAt;

  GroupModel({
    required this.admins,
    required this.users,
    required this.id,
    required this.name,
    required this.about,
    required this.image,
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> map) {
    return GroupModel(
      admins: (map['admins'] as List<dynamic>).map((e) => e as String).toList(),
      users: (map['users'] as List<dynamic>).map((e) => e as String).toList(),
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      about: map['about'] ?? "",
      image: map['image'] ?? "",
      createdAt: map['createdAt'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admins': admins,
      'users': users,
      'id': id,
      'name': name,
      'about': about,
      'image': image,
      'createdAt': createdAt,
    };
  }
}
