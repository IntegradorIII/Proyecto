class User {
  final int id;
  final String name;
  final String iden;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.iden,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.tryParse(json["id"].toString()) ?? 0,
      name: (json["nombre"] ?? '').toString(),
      iden: (json["cedula"] ?? '').toString(),
      email: (json["correo"] ?? '').toString(),
      role: (json["rol"] ?? '').toString(),
    );
  }
}