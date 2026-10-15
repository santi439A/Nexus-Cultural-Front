class UserSession {
  final String email;
  final String token;
  final String rol;
  final int expiracionEnSegundos;

  UserSession({
    required this.email,
    required this.token,
    required this.rol,
    required this.expiracionEnSegundos,
  });

  bool get isComprador => rol.toUpperCase() == 'COMPRADOR';
  bool get isArtesano => rol.toUpperCase() == 'ARTESANO';
  bool get isAdmin => rol.toUpperCase() == 'ADMINISTRADOR' || rol.toUpperCase() == 'ADMIN';

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      expiracionEnSegundos: json['expiracionEnSegundos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'token': token,
      'rol': rol,
      'expiracionEnSegundos': expiracionEnSegundos,
    };
  }
}
