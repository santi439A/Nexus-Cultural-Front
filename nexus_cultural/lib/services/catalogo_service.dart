import '../shared/network/api_client.dart';
import '../models/articulo_model.dart';

class CatalogoService {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/catalogo — Lista catálogo general o filtrado por grupo
  Future<List<ArticuloModel>> obtenerCatalogo({String? grupo}) async {
    final Map<String, dynamic> queryParams = {};
    if (grupo != null && grupo.isNotEmpty) {
      queryParams['grupo'] = grupo;
    }

    final response = await _apiClient.get(
      '/catalogo',
      queryParameters: queryParams,
    );

    final List data = response.data;
    return data.map((json) => ArticuloModel.fromJson(json)).toList();
  }

  /// GET /api/catalogo/buscar?query= — Búsqueda por palabra clave o título
  Future<List<ArticuloModel>> buscarCatalogo(String query) async {
    final response = await _apiClient.get(
      '/catalogo/buscar',
      queryParameters: {'query': query},
    );

    final List data = response.data;
    return data.map((json) => ArticuloModel.fromJson(json)).toList();
  }

  /// GET /api/catalogo/categorias — Lista los valores del enum Grupo
  Future<List<String>> obtenerCategorias() async {
    final response = await _apiClient.get('/catalogo/categorias');
    return List<String>.from(response.data);
  }

  /// GET /api/catalogo/artesano/{artesanoId} — Artículos de un artesano específico
  Future<List<ArticuloModel>> obtenerPorArtesano(String artesanoId) async {
    final response = await _apiClient.get('/catalogo/artesano/$artesanoId');
    final List data = response.data;
    return data.map((json) => ArticuloModel.fromJson(json)).toList();
  }

  /// GET /api/articulos/{id} — Detalle por ID de artículo
  Future<ArticuloModel> obtenerArticuloPorId(String id) async {
    final response = await _apiClient.get('/articulos/$id');
    return ArticuloModel.fromJson(response.data);
  }
}