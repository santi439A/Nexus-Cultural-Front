import 'artisan_model.dart';

class ArticuloModel {
  final String id;
  final String artesanoId;
  final String titulo;
  final String descripcion;
  final double montoPrecio;
  final String moneda;
  final int stock;
  final String estado;
  final String grupo;
  final List<String> imagenes;
  final DateTime? fechaPublicacion;
  final double? precioConDescuento;
  final int? porcentajeDescuento;

  ArticuloModel({
    required this.id,
    required this.artesanoId,
    required this.titulo,
    required this.descripcion,
    required this.montoPrecio,
    required this.moneda,
    required this.stock,
    required this.estado,
    required this.grupo,
    required this.imagenes,
    this.fechaPublicacion,
    this.precioConDescuento,
    this.porcentajeDescuento,
  });

  ArticuloModel copyWith({
    String? id,
    String? artesanoId,
    String? titulo,
    String? descripcion,
    double? montoPrecio,
    String? moneda,
    int? stock,
    String? estado,
    String? grupo,
    List<String>? imagenes,
    DateTime? fechaPublicacion,
    double? precioConDescuento,
    int? porcentajeDescuento,
  }) {
    return ArticuloModel(
      id: id ?? this.id,
      artesanoId: artesanoId ?? this.artesanoId,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      montoPrecio: montoPrecio ?? this.montoPrecio,
      moneda: moneda ?? this.moneda,
      stock: stock ?? this.stock,
      estado: estado ?? this.estado,
      grupo: grupo ?? this.grupo,
      imagenes: imagenes ?? this.imagenes,
      fechaPublicacion: fechaPublicacion ?? this.fechaPublicacion,
      precioConDescuento: precioConDescuento ?? this.precioConDescuento,
      porcentajeDescuento: porcentajeDescuento ?? this.porcentajeDescuento,
    );
  }

  double get precioEfectivo => precioConDescuento ?? montoPrecio;

  ProductModel toProductModel({ArtisanModel? defaultArtisan}) {
    return ProductModel(
      id: id,
      name: titulo,
      tagline: descripcion,
      category: grupo,
      region: 'Colombia',
      department: 'Colombia',
      price: precioEfectivo,
      artisan: defaultArtisan ??
          ArtisanModel(
            id: artesanoId.isNotEmpty ? artesanoId : 'art-default',
            name: 'Maestro Artesano',
            community: 'Comunidad Tradicional',
            department: 'Colombia',
            municipality: 'Colombia',
            avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
            bio: 'Maestro artesano tradicional colombiano.',
            verified: true,
            yearsOfExperience: 25,
            techniques: const ['Elaboración a mano tradicional'],
            phone: '+57 300 000 0000',
          ),
      images: imagenes.isNotEmpty
          ? imagenes
          : [
              'https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&w=600&q=80',
            ],
      rating: 4.9,
      reviewsCount: 15,
      storyQuote: descripcion,
      technique: 'Artesanía hecha a mano',
      craftingTime: '15 días',
      symbolism: descripcion,
      dimensions: 'Medidas tradicionales',
      stock: stock,
      isFamilyWorkshop: true,
    );
  }

  factory ArticuloModel.fromJson(Map<String, dynamic> json) {
    return ArticuloModel(
      id: json['id'] ?? '',
      artesanoId: json['artesanoId'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      montoPrecio: (json['montoPrecio'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda'] ?? 'COP',
      stock: json['stock'] ?? 0,
      estado: json['estado'] ?? 'ACTIVO',
      grupo: json['grupo'] ?? 'GENERAL',
      imagenes: json['imagenes'] != null
          ? List<String>.from(json['imagenes'])
          : [],
      fechaPublicacion: json['fechaPublicacion'] != null
          ? DateTime.tryParse(json['fechaPublicacion'].toString())
          : null,
      precioConDescuento: (json['precioConDescuento'] as num?)?.toDouble(),
      porcentajeDescuento: json['porcentajeDescuento'] as int?,
    );
  }
}