class CompradorRequest {
  final String nombreCompleto;
  final String email;
  final String departamento;
  final String municipio;
  final String direccion;

  CompradorRequest({
    required this.nombreCompleto,
    required this.email,
    required this.departamento,
    required this.municipio,
    required this.direccion,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreCompleto': nombreCompleto,
      'email': email,
      'departamento': departamento,
      'municipio': municipio,
      'direccion': direccion,
    };
  }
}
