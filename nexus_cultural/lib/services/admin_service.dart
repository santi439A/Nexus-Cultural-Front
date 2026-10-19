import '../features/authentication/models/admin_model.dart';
import '../features/authentication/models/administrador_request.dart';
import '../shared/network/api_client.dart';

class AdminService {
  final ApiClient _apiClient = ApiClient();

  /// GET /api/administradores — Lista todos los administradores desde la base de datos
  Future<List<AdminModel>> obtenerAdministradores() async {
    final response = await _apiClient.get('/administradores');
    final List data = response.data;
    return data.map((json) => AdminModel.fromJson(json)).toList();
  }

  /// POST /api/administradores — Registra un nuevo administrador
  Future<AdminModel> registrarAdministrador(AdministradorRequest request) async {
    final response = await _apiClient.post(
      '/administradores',
      data: request.toJson(),
    );
    return AdminModel.fromJson(response.data);
  }

  /// PUT /api/administradores/{id} — Actualiza los datos del administrador
  Future<AdminModel> actualizarAdministrador({
    required String id,
    required String nombreCompleto,
    required String nivelAcceso,
  }) async {
    final response = await _apiClient.put(
      '/administradores/$id',
      data: {
        'nombreCompleto': nombreCompleto,
        'nivelAcceso': nivelAcceso,
      },
    );
    return AdminModel.fromJson(response.data);
  }

  /// PUT /api/administradores/{id}/nivel_acceso — Actualiza solo el nivel de acceso
  Future<bool> cambiarNivelAcceso({
    required String id,
    required String nivelAcceso,
  }) async {
    final response = await _apiClient.put(
      '/administradores/$id/nivel_acceso',
      data: {'nivelAcceso': nivelAcceso},
    );
    return response.statusCode == 200;
  }

  /// DELETE /api/administradores/{id} — Elimina un administrador de la base de datos
  Future<bool> eliminarAdministrador(String id) async {
    final response = await _apiClient.delete('/administradores/$id');
    return response.statusCode == 204 || response.statusCode == 200;
  }
}
