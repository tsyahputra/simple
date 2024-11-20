import 'instance.dart';
import 'role.dart';

class User {
  int? id;
  String nama;
  String email;
  int instanceId;
  int roleId;
  String? hashToken;
  String? fcmToken;
  DateTime? modified;
  Role? role;
  Instance? instance;

  User({
    this.id,
    required this.nama,
    required this.email,
    required this.instanceId,
    required this.roleId,
    this.hashToken,
    this.fcmToken,
    this.role,
    this.instance,
    this.modified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        nama: json["nama"],
        email: json["email"],
        instanceId: json["instance_id"],
        roleId: json["role_id"],
        hashToken: json["hash_token"] ?? '',
        fcmToken: json["fcm_token"] ?? '',
        modified: DateTime.parse(json["modified"]),
        instance: Instance.fromJson(json["instance"]),
        role: Role.fromJson(json["role"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? 0,
        "nama": nama,
        "email": email,
        "instance_id": instanceId,
        "role_id": roleId,
        "hash_token": hashToken ?? "",
        "fcm_token": fcmToken ?? "",
        "modified": modified?.toIso8601String(),
        "instance": instance?.toJson(),
        "role": role?.toJson()
      };
}

class Users {
  List<User> users;
  int? total;

  Users({
    required this.users,
    this.total,
  });

  factory Users.fromJson(Map<String, dynamic> json) => Users(
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
        total: json["total"] ?? 0,
      );
}

class UserLoggedIn {
  User? user;
  String? accessToken;
  String? refreshToken;

  UserLoggedIn({
    required this.user,
    this.accessToken,
    this.refreshToken,
  });

  factory UserLoggedIn.fromJson(Map<String, dynamic> json) => UserLoggedIn(
        user: User.fromJson(json["user"]),
        accessToken: json["access_token"],
        refreshToken: json["refresh_token"],
      );

  Map<String, dynamic> toJson() => {
        "user": user!.toJson(),
        "access_token": accessToken,
        "refresh_token": refreshToken,
      };
}
