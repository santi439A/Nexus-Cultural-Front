import '../shared/network/api_client.dart';
import '../models/order_model.dart';
import 'catalogo_service.dart';

class CarritoBackendItem {
  final String id;
  final String compradorId;
  final String articuloId;
  final int cantidad;

  CarritoBackendItem({
    required this.id,
    required this.compradorId,
    required this.articuloId,
    required this.cantidad,
  });

  factory CarritoBackendItem.fromJson(Map<String, dynamic> json) {
    return CarritoBackendItem(
      id: json['id']?.toString() ?? '',
      compradorId: json['compradorId']?.toString() ?? '',
      articuloId: json['articuloId']?.toString() ?? '',
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
    );
  }
}

class CarritoService {
  final ApiClient _apiClient = ApiClient();
  final CatalogoService _catalogoService = CatalogoService();

  /// GET /api/compradores/{compradorId}/carrito
  Future<List<CartItemModel>> obtenerCarrito(String compradorId) async {
    try {
      final response = await _apiClient.get('/compradores/$compradorId/carrito');
      final List data = response.data;
      final backendItems = data.map((json) => CarritoBackendItem.fromJson(json)).toList();

      final List<CartItemModel> result = [];
      for (final item in backendItems) {
        try {
          final articulo = await _catalogoService.obtenerArticuloPorId(item.articuloId);
          result.add(CartItemModel(
            product: articulo.toProductModel(),
            quantity: item.cantidad,
          ));
        } catch (_) {
          // Si no se pudo obtener detalle, omitir o continuar
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  /// POST /api/compradores/{compradorId}/carrito/items
  Future<bool> agregarItem(String compradorId, String articuloId, int cantidad) async {
    try {
      await _apiClient.post(
        '/compradores/$compradorId/carrito/items',
        data: {
          'articuloId': articuloId,
          'cantidad': cantidad,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// PUT /api/compradores/{compradorId}/carrito/items/{itemId}
  Future<bool> actualizarCantidad(String compradorId, String itemId, int cantidad) async {
    try {
      await _apiClient.put(
        '/compradores/$compradorId/carrito/items/$itemId',
        data: {
          'cantidad': cantidad,
        },
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// DELETE /api/compradores/{compradorId}/carrito/items/{itemId}
  Future<bool> eliminarItem(String compradorId, String itemId) async {
    try {
      await _apiClient.delete('/compradores/$compradorId/carrito/items/$itemId');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// DELETE /api/compradores/{compradorId}/carrito
  Future<bool> vaciarCarrito(String compradorId) async {
    try {
      await _apiClient.delete('/compradores/$compradorId/carrito');
      return true;
    } catch (_) {
      return false;
    }
  }
}
