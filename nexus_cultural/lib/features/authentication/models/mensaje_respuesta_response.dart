class MensajeRespuestaResponse {
  final String mensaje;
  final bool exitoso;

  MensajeRespuestaResponse({
    required this.mensaje,
    required this.exitoso,
  });

  factory MensajeRespuestaResponse.fromJson(Map<String, dynamic> json) {
    return MensajeRespuestaResponse(
      mensaje: json['mensaje'] as String? ?? '',
      exitoso: json['exitoso'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mensaje': mensaje,
      'exitoso': exitoso,
    };
  }
}
