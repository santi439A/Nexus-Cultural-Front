class ArtesanoRequest {
  final String nombreCompleto;
  final String email;
  final int anosExperiencia;
  final List<String> reconocimientos;
  final String departamento;
  final String municipio;
  final String direccion;

  ArtesanoRequest({
    required this.nombreCompleto,
    required this.email,
    required this.anosExperiencia,
    required this.reconocimientos,
    required this.departamento,
    required this.municipio,
    required this.direccion,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombreCompleto': nombreCompleto,
      'email': email,
      'anosExperiencia': anosExperiencia,
      'reconocimientos': reconocimientos,
      'departamento': departamento,
      'municipio': municipio,
      'direccion': direccion,
    };
  }
}
