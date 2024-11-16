import 'instance.dart';

class Role {
  int? id;
  String nama;

  Role({this.id, required this.nama});

  factory Role.fromJson(Map<String, dynamic> json) => Role(
        id: json["id"],
        nama: json["nama"],
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? 0,
        "nama": nama,
      };
}

class InstancesRoles {
  List<Instance> instances;
  List<Role> roles;

  InstancesRoles({required this.instances, required this.roles});

  factory InstancesRoles.fromJson(Map<String, dynamic> json) => InstancesRoles(
        instances: List<Instance>.from(
            json["instances"].map((x) => Instance.fromJson(x))),
        roles: List<Role>.from(json["roles"].map((x) => Role.fromJson(x))),
      );
}
