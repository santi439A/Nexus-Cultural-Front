import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/artisan_model.dart';
import '../models/order_model.dart';
import '../shared/network/api_client.dart';
import 'carrito_service.dart';

// User Roles
enum UserRole { artisan, buyer, familySupport, culturalManager, admin }

final userRoleProvider = StateProvider<UserRole>((ref) => UserRole.artisan);

// Mock Authentic Colombian Artisans
final sampleArtisans = [
  const ArtisanModel(
    id: 'art-maria-pushaina',
    name: 'Doña María José Pushaina',
    community: 'Clan Pushaina · Pueblo Wayúu',
    department: 'La Guajira',
    municipality: 'Uribia (Capital Indígena de Colombia)',
    avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
    bio: 'Maestra tejedora con más de 38 años transmitiendo el arte ancestral del tejido Susu en hilo silvestre.',
    verified: true,
    yearsOfExperience: 38,
    techniques: ['Tejido a mano en una hebra', 'Kanaas geométricos sagrados'],
    phone: '+57 312 456 7890',
  ),
  const ArtisanModel(
    id: 'art-carmen-silva',
    name: 'Maestro Carmen Silva',
    community: 'Vereda La Chamba',
    department: 'Tolima',
    municipality: 'Guamo',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
    bio: 'Alfarero tradicional de cuarta generación, modelador en torno y bruñido con piedra de río.',
    verified: true,
    yearsOfExperience: 42,
    techniques: ['Barro negro bruñido', 'Cocción en horno de leña abierta'],
    phone: '+57 311 889 2234',
  ),
];

// Mock Colombian Artisan Products
final sampleProducts = [
  ProductModel(
    id: 'prod-wayuu-susu',
    name: 'Mochila Artesanal Wayúu Susu',
    tagline: 'Hilos de algodón puro con diseño Kanaas sagrado',
    category: 'Tejido',
    region: 'La Guajira',
    department: 'La Guajira',
    price: 180000.0,
    artisan: sampleArtisans[0],
    images: [
      'https://images.unsplash.com/photo-1590736969955-71cc94801759?auto=format&fit=crop&w=600&q=80',
      'https://images.unsplash.com/photo-1606760227091-3dd870d97f1d?auto=format&fit=crop&w=600&q=80',
    ],
    rating: 4.9,
    reviewsCount: 38,
    storyQuote: 'Cada figura geométrica cuenta el camino de las constelaciones sobre el desierto.',
    technique: 'Ganchillo tradicional en una sola hebra (25 días de tejido continuo)',
    craftingTime: '25 días',
    symbolism: 'Kanaas Iwouya (Estrella que anuncia la época de lluvias)',
    dimensions: 'Alto 30 cm, Diámetro 22 cm, Gasa 105 cm',
    stock: 4,
    isFamilyWorkshop: true,
  ),
  ProductModel(
    id: 'prod-chamba-jarron',
    name: 'Jarrón Ancestral en Barro Negro',
    tagline: 'Arcilla natural pulida a mano con piedra de río',
    category: 'Cerámica',
    region: 'Tolima',
    department: 'Tolima',
    price: 110000.0,
    artisan: sampleArtisans[1],
    images: [
      'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?auto=format&fit=crop&w=600&q=80',
    ],
    rating: 4.8,
    reviewsCount: 24,
    storyQuote: 'El color negro profundo se obtiene mediante ahumado con hoja de plátano seco.',
    technique: 'Moldeado manual y bruñido con ágata de río',
    craftingTime: '12 días',
    symbolism: 'Vasija ceremonial para agua fresca y vida comunitaria',
    dimensions: 'Alto 28 cm, Boca 15 cm, Peso 2.1 kg',
    stock: 2,
    isFamilyWorkshop: true,
  ),
];

// Product List State Notifier with Backend Catalogo Sync
class ProductsNotifier extends StateNotifier<List<ProductModel>> {
  final ApiClient _apiClient = ApiClient();

  ProductsNotifier() : super(sampleProducts) {
    cargarCatalogoDesdeServidor();
  }

  Future<void> cargarCatalogoDesdeServidor({String? query, String? grupo}) async {
    try {
      String path = '/catalogo';
      Map<String, dynamic> params = {};
      if (query != null && query.trim().isNotEmpty) {
        path = '/catalogo/buscar';
        params['query'] = query.trim();
      } else if (grupo != null && grupo.trim().isNotEmpty) {
        params['grupo'] = grupo.trim();
      }

      final response = await _apiClient.get(
        path,
        queryParameters: params.isNotEmpty ? params : null,
      );

      if (response.data is List && (response.data as List).isNotEmpty) {
        final serverProducts = (response.data as List).map<ProductModel>((item) {
          final map = item as Map<String, dynamic>;
          final id = map['id']?.toString() ?? 'prod-${DateTime.now().millisecondsSinceEpoch}';
          final titulo = map['titulo']?.toString() ?? 'Artesanía Colombiana';
          final descripcion = map['descripcion']?.toString() ?? 'Pieza auténtica hecha a mano';
          final double precio = (map['montoPrecio'] as num?)?.toDouble() ??
              (map['precioConDescuento'] as num?)?.toDouble() ??
              150000.0;
          final int stock = (map['stock'] as num?)?.toInt() ?? 1;
          final String grupoNombre = map['grupo']?.toString() ?? 'Tejido';
          List<String> imagenes = [];
          if (map['imagenes'] is List && (map['imagenes'] as List).isNotEmpty) {
            imagenes = (map['imagenes'] as List).map((img) => img.toString()).toList();
          } else {
            imagenes = sampleProducts[0].images;
          }

          return ProductModel(
            id: id,
            name: titulo,
            tagline: descripcion,
            category: grupoNombre,
            region: 'Colombia',
            department: 'Colombia',
            price: precio,
            artisan: ArtisanModel(
              id: map['artesanoId']?.toString() ?? sampleArtisans[0].id,
              name: map['artesanoNombre']?.toString() ?? sampleArtisans[0].name,
              community: sampleArtisans[0].community,
              department: sampleArtisans[0].department,
              municipality: sampleArtisans[0].municipality,
              avatarUrl: sampleArtisans[0].avatarUrl,
              bio: sampleArtisans[0].bio,
              verified: true,
              yearsOfExperience: sampleArtisans[0].yearsOfExperience,
              techniques: sampleArtisans[0].techniques,
              phone: sampleArtisans[0].phone,
            ),
            images: imagenes,
            rating: 4.9,
            reviewsCount: 30,
            storyQuote: descripcion,
            technique: 'Oficio y memoria ancestral tradicional',
            craftingTime: '15 días',
            symbolism: 'Sello de origen y tradición artesanal',
            dimensions: 'Dimensiones estándar de taller',
            stock: stock,
            isFamilyWorkshop: true,
          );
        }).toList();

        state = [...serverProducts, ...sampleProducts];
      }
    } catch (_) {
      // Fallback a las obras de muestra colombianas
    }
  }

  void addProduct(ProductModel product) {
    state = [product, ...state];
  }
}

final productsProvider = StateNotifierProvider<ProductsNotifier, List<ProductModel>>((ref) {
  return ProductsNotifier();
});

// Selected Product
final selectedProductProvider = StateProvider<ProductModel>((ref) => sampleProducts[0]);

// Favorites Provider
class FavoritesNotifier extends StateNotifier<List<ProductModel>> {
  FavoritesNotifier() : super([sampleProducts[0]]);

  void toggleFavorite(ProductModel product) {
    if (state.any((p) => p.id == product.id)) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }
  }

  bool isFavorite(String id) => state.any((p) => p.id == id);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<ProductModel>>(
  (ref) => FavoritesNotifier(),
);

// Cart Notifier
class CartNotifier extends StateNotifier<List<CartItemModel>> {
  final CarritoService _carritoService = CarritoService();

  CartNotifier() : super([]); // Comienza vacío; se llena desde la base de datos o al agregar

  Future<void> cargarCarritoDesdeServidor(String compradorId) async {
    try {
      final items = await _carritoService.obtenerCarrito(compradorId);
      state = items;
    } catch (_) {
      // Si falla o no hay nada agregado, queda vacío
    }
  }

  Future<void> addItem(ProductModel product, [int quantity = 1, String? compradorId]) async {
    final index = state.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final current = state[index];
      state = [
        ...state.sublist(0, index),
        current.copyWith(quantity: current.quantity + quantity),
        ...state.sublist(index + 1),
      ];
    } else {
      state = [...state, CartItemModel(product: product, quantity: quantity)];
    }

    if (compradorId != null && compradorId.isNotEmpty) {
      await _carritoService.agregarItem(compradorId, product.id, quantity);
    }
  }

  Future<void> updateQuantity(String productId, int quantity, [String? compradorId]) async {
    if (quantity <= 0) {
      await removeItem(productId, compradorId);
      return;
    }
    state = state.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();
  }

  Future<void> removeItem(String productId, [String? compradorId]) async {
    state = state.where((item) => item.product.id != productId).toList();
  }

  Future<void> clear([String? compradorId]) async {
    state = [];
    if (compradorId != null && compradorId.isNotEmpty) {
      await _carritoService.vaciarCarrito(compradorId);
    }
  }

  double get subtotal => state.fold(0, (sum, item) => sum + item.subtotal);
  double get shippingCost => state.isEmpty ? 0 : 15000.0;
  double get total => subtotal + shippingCost;
  double get artisanDirectPayout => subtotal * 0.90; // 90% direct to elderly artisan
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>(
  (ref) => CartNotifier(),
);

// Active Order
final sampleInitialOrder = OrderModel(
  id: 'ord-0412',
  orderNumber: 'NEX-2026-0412',
  orderDate: '15 de Octubre 2026',
  items: [
    CartItemModel(product: sampleProducts[0], quantity: 1),
    CartItemModel(product: sampleProducts[1], quantity: 1),
  ],
  totalAmount: 305000.0,
  artisanDirectPayout: 261000.0,
  shippingAddress: const ShippingAddressModel(
    fullName: 'María Camila Rosero',
    phone: '+57 312 456 7890',
    department: 'Cundinamarca',
    city: 'Bogotá D.C.',
    address: 'Carrera 7 # 115 - 45, Torre B, Apto 402',
    deliveryNotes: 'Dejar en recepción 24 horas. Producto frágil.',
  ),
  paymentMethod: PaymentMethodType.card,
  carrierName: 'Coordinadora Mercantil Artesanal',
  trackingGuide: '984210',
  currentStage: 4, // En camino a tu ciudad
  estimatedDelivery: '19 - 21 de Octubre 2026',
  dedicationNote: 'Muchísimas gracias doña María y maestro Carmen por preservar nuestra memoria ancestral.',
);

final activeOrderProvider = StateProvider<OrderModel>((ref) => sampleInitialOrder);

// Shipping Form State
final shippingFormProvider = StateProvider<ShippingAddressModel>((ref) => const ShippingAddressModel(
  fullName: 'María Camila Rosero',
  phone: '+57 312 456 7890',
  department: 'Cundinamarca (Usaquén)',
  city: 'Bogotá D.C.',
  address: 'Carrera 7 # 115 - 45, Torre B, Apto 402',
  deliveryNotes: 'Por favor entregar en portería las 24 horas, empaque frágil.',
));
