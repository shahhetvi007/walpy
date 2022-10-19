class User {
  String id;
  String email;
  String username;
  String photoUrl;
  bool isAdmin;

  User(
      {required this.id,
      required this.email,
      required this.username,
      required this.photoUrl,
      this.isAdmin = false});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      username: map['username'],
      photoUrl: map['photoUrl'],
      isAdmin: map['isAdmin'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
    };
  }
}
