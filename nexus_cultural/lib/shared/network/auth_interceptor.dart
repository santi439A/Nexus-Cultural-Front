import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthInterceptor extends Interceptor {
  // Endpoints públicos donde no se debe enviar cabecera Authorization (para evitar que tokens viejos o expirados interfieran en el registro o login)
  static const List<String> _publicEndpoints = [
    '/usuarios/solicitar',
    '/usuarios/verificar',
    '/compradores',
    '/artesanos',
    '/administradores',
  ];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final isPublicEndpoint = _publicEndpoints.any((endpoint) => options.path.endsWith(endpoint));
    if (isPublicEndpoint) {
      // Remueve cualquier header Authorization previo para peticiones anónimas
      options.headers.remove('Authorization');
      return handler.next(options);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Si no se puede acceder a SharedPreferences, continúa sin token
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Manejar token expirado o no autorizado si es necesario
    }
    return handler.next(err);
  }
}
