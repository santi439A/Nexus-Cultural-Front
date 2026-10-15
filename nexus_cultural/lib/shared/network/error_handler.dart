import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String parseError(dynamic error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          // 1. Si viene con mapa de 'errores' de validación (MethodArgumentNotValidException)
          if (data['errores'] != null && data['errores'] is Map) {
            final Map<dynamic, dynamic> errores = data['errores'];
            if (errores.isNotEmpty) {
              return errores.values.map((v) => '• $v').join('\n');
            }
          }

          // 2. Si viene con 'mensaje' del GlobalExceptionHandler
          if (data['mensaje'] != null && data['mensaje'].toString().isNotEmpty) {
            return data['mensaje'].toString();
          }

          // 3. Fallback de Spring estándar 'message' o 'error'
          if (data['message'] != null && data['message'].toString().isNotEmpty) {
            return data['message'].toString();
          }
        }
        return 'Error del servidor (${error.response?.statusCode})';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Tiempo de espera agotado. Verifica tu conexión con el backend.';
        case DioExceptionType.connectionError:
          return 'No se pudo conectar con el servidor backend. Verifica que Spring Boot esté corriendo en el puerto configurado.';
        case DioExceptionType.cancel:
          return 'La solicitud fue cancelada.';
        default:
          return 'Error en la comunicación con el servidor.';
      }
    }

    return error.toString();
  }
}
