class UserSession {
  final String? id;
  final String email;
  final String token;
  final String rol;
  final int expiracionEnSegundos;
  final String? nivelAcceso;

  UserSession({
    this.id,
    required this.email,
    required this.token,
    required this.rol,
    required this.expiracionEnSegundos,
    this.nivelAcceso,
  });

  bool get isComprador => rol.toUpperCase() == 'COMPRADOR' || rol.toUpperCase() == 'BUYER';
  bool get isArtesano => rol.toUpperCase() == 'ARTESANO' || rol.toUpperCase() == 'ARTISAN';
  bool get isAdmin => rol.toUpperCase() == 'ADMINISTRADOR' || rol.toUpperCase() == 'ADMIN';
  bool get isSuperAdmin => isAdmin && (nivelAcceso == null || nivelAcceso == 'SUPER_ADMIN');

  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      id: json['id'] as String?,
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
      rol: json['rol'] as String? ?? '',
      expiracionEnSegundos: json['expiracionEnSegundos'] as int? ?? 0,
      nivelAcceso: json['nivelAcceso'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'email': email,
      'token': token,
      'rol': rol,
      'expiracionEnSegundos': expiracionEnSegundos,
      if (nivelAcceso != null) 'nivelAcceso': nivelAcceso,
    };
  }
}

