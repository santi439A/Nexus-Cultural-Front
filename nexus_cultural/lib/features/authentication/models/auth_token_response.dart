class AuthTokenResponse {
  final String token;
  final String tipo;
  final String rol;
  final int expiracionEnSegundos;

  AuthTokenResponse({
    required this.token,
    required this.tipo,
    required this.rol,
    required this.expiracionEnSegundos,
  });

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      token: json['token'] as String? ?? '',
      tipo: json['tipo'] as String? ?? 'Bearer',
      rol: json['rol'] as String? ?? '',
      expiracionEnSegundos: json['expiracionEnSegundos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'tipo': tipo,
      'rol': rol,
      'expiracionEnSegundos': expiracionEnSegundos,
    };
  }
}
