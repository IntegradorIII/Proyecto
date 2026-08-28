import 'user.dart';

class LoginResponse {
  final String token;
  final User usuario;

  LoginResponse({
    required this.token,
    required this.usuario,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json["token"],
      usuario: User.fromJson(json["usuario"]),
    );
  }
}