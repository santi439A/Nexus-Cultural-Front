class AdminModel {
  final String id;
  final String nombreCompleto;
  final String email;
  final String nivelAcceso;
  final DateTime fechaRegistro;

  AdminModel({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.nivelAcceso,
    required this.fechaRegistro,
  });

  AdminModel copyWith({
    String? id,
    String? nombreCompleto,
    String? email,
    String? nivelAcceso,
    DateTime? fechaRegistro,
  }) {
    return AdminModel(
      id: id ?? this.id,
      nombreCompleto: nombreCompleto ?? this.nombreCompleto,
      email: email ?? this.email,
      nivelAcceso: nivelAcceso ?? this.nivelAcceso,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['id']?.toString() ?? '',
      nombreCompleto: json['nombreCompleto']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nivelAcceso: json['nivelAcceso']?.toString() ?? 'SUPER_ADMIN',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.tryParse(json['fechaRegistro'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'nivelAcceso': nivelAcceso,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }
}
