class AdministradorRequest {
  final String nombreCompleto;
  final String email;
  final String nivelAcceso; // SUPER_ADMIN, MODERADOR_CONTENIDO, SOPORTE, GESTOR_CULTURAL

  AdministradorRequest({
    required this.nombreCompleto,
    required this.email,
    required this.nivelAcceso,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreCompleto': nombreCompleto,
      'email': email,
      'nivelAcceso': nivelAcceso,
    };
  }
}
