class Instance {
  int? id;
  String nama;
  String? alamat;
  String? kabupaten;
  String provinsi;
  String? telp;
  String? email;
  DateTime? modified;

  Instance({
    this.id,
    required this.nama,
    this.alamat,
    this.kabupaten,
    required this.provinsi,
    this.telp,
    this.email,
    this.modified,
  });

  factory Instance.fromJson(Map<String, dynamic> json) => Instance(
        id: json["id"],
        nama: json["nama"],
        alamat: json["alamat"],
        kabupaten: json["kabupaten"],
        provinsi: json["provinsi"],
        telp: json["telp"],
        email: json["email"],
        modified:
            json["modified"] == null ? null : DateTime.parse(json["modified"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id ?? 0,
        "nama": nama,
        "alamat": alamat?.toString(),
        "kabupaten": kabupaten?.toString(),
        "provinsi": provinsi,
        "telp": telp?.toString(),
        "email": email?.toString(),
        "modified": modified?.toIso8601String(),
      };
}

class Instances {
  Instances({
    required this.instances,
    required this.total,
  });

  List<Instance> instances;
  int total;

  factory Instances.fromJson(Map<String, dynamic> json) => Instances(
        instances: List<Instance>.from(
            json["instances"].map((x) => Instance.fromJson(x))),
        total: json["total"],
      );
}
