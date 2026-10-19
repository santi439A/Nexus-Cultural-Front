import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/network/api_client.dart';
import '../../../shared/network/error_handler.dart';
import '../models/auth_token_response.dart';
import '../models/mensaje_respuesta_response.dart';
import '../models/comprador_request.dart';
import '../models/artesano_request.dart';
import '../models/administrador_request.dart';
import '../models/user_session.dart';

enum LoginStep { enterEmail, enterOtp }

class AuthController extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  LoginStep _currentStep = LoginStep.enterEmail;
  LoginStep get currentStep => _currentStep;

  String _emailSolicitado = '';
  String get emailSolicitado => _emailSolicitado;

  UserSession? _userSession;
  UserSession? get userSession => _userSession;

  bool get isAuthenticated => _userSession != null && _userSession!.token.isNotEmpty;
  String? get currentUserRole => _userSession?.rol;
  String? get currentUserEmail => _userSession?.email;
  String? get currentUserId => _userSession?.id;

  bool get isArtisan {
    final r = currentUserRole?.trim().toUpperCase();
    return r == 'ARTESANO' || r == 'ARTISAN';
  }

  bool get isBuyer {
    final r = currentUserRole?.trim().toUpperCase();
    return r == 'COMPRADOR' || r == 'BUYER';
  }

  bool get isAdmin {
    final r = currentUserRole?.trim().toUpperCase();
    return r == 'ADMINISTRADOR' || r == 'ADMIN';
  }

  String? _currentNivelAcceso;
  String get currentAdminNivelAcceso =>
      _currentNivelAcceso ?? _userSession?.nivelAcceso ?? 'SUPER_ADMIN';

  void setSimulatedNivelAcceso(String nivel) {
    _currentNivelAcceso = nivel;
    notifyListeners();
  }

  AuthController() {
    checkCurrentSession();
  }

  // Verifica si hay una sesión activa guardada
  Future<void> checkCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('auth_email');
      final rol = prefs.getString('auth_rol') ?? (token != null ? _extractRolFromToken(token) : null);
      final id = prefs.getString('auth_user_id') ?? (token != null ? _extractUserIdFromToken(token) : null);
      final expiracion = prefs.getInt('auth_expiracion') ?? 0;
      final nivelAcceso = prefs.getString('auth_nivel_acceso');

      if (token != null && token.isNotEmpty && email != null && rol != null) {
        _userSession = UserSession(
          id: id,
          email: email,
          token: token,
          rol: rol,
          expiracionEnSegundos: expiracion,
          nivelAcceso: nivelAcceso,
        );
        _currentNivelAcceso = nivelAcceso;
        notifyListeners();
      }
    } catch (_) {}
  }

  // Paso 1 de Login: Solicitar código OTP al backend
  Future<bool> solicitarOtp(String email) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiClient.post(
        '/usuarios/solicitar',
        data: {'email': email.trim()},
      );

      final data = response.data;
      final respuesta = MensajeRespuestaResponse.fromJson(data);

      _emailSolicitado = email.trim();
      _currentStep = LoginStep.enterOtp;
      _successMessage = respuesta.mensaje.isNotEmpty
          ? respuesta.mensaje
          : 'Código OTP enviado exitosamente a $email';

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = ApiErrorHandler.parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // Paso 2 de Login: Validar código OTP y recibir token JWT
  Future<bool> verificarOtp(String email, String codigo) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiClient.post(
        '/usuarios/verificar',
        data: {
          'email': email.trim(),
          'codigo': codigo.trim(),
        },
      );

      final data = response.data;
      final authResponse = AuthTokenResponse.fromJson(data);
      final userId = _extractUserIdFromToken(authResponse.token);
      final rolFromToken = _extractRolFromToken(authResponse.token);
      final rol = (authResponse.rol.isNotEmpty ? authResponse.rol : rolFromToken) ?? 'COMPRADOR';

      String? nivelAcceso;
      if (rol.toUpperCase() == 'ADMINISTRADOR' || rol.toUpperCase() == 'ADMIN') {
        try {
          if (userId != null && userId.isNotEmpty) {
            final adminRes = await _apiClient.get('/administradores/$userId');
            if (adminRes.statusCode == 200 && adminRes.data != null) {
              nivelAcceso = adminRes.data['nivelAcceso']?.toString();
            }
          }
        } catch (_) {}
        nivelAcceso ??= 'SUPER_ADMIN';
      }
      _currentNivelAcceso = nivelAcceso;

      // Guardar en sesión
      _userSession = UserSession(
        id: userId,
        email: email.trim(),
        token: authResponse.token,
        rol: rol,
        expiracionEnSegundos: authResponse.expiracionEnSegundos,
        nivelAcceso: nivelAcceso,
      );

      // Persistir token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authResponse.token);
      await prefs.setString('auth_rol', rol);
      await prefs.setString('auth_email', email.trim());
      if (userId != null) await prefs.setString('auth_user_id', userId);
      await prefs.setInt('auth_expiracion', authResponse.expiracionEnSegundos);
      if (nivelAcceso != null) await prefs.setString('auth_nivel_acceso', nivelAcceso);

      _successMessage = '¡Bienvenido! Sesión iniciada con rol: $rol';
      _currentStep = LoginStep.enterEmail;

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = ApiErrorHandler.parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // Registro: Comprador
  Future<bool> registrarComprador(CompradorRequest request) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiClient.post(
        '/compradores',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _successMessage = 'Comprador registrado exitosamente. Ahora puedes solicitar tu código de acceso.';
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'No se pudo completar el registro.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = ApiErrorHandler.parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // Registro: Artesano
  Future<bool> registrarArtesano(ArtesanoRequest request) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiClient.post(
        '/artesanos',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _successMessage = 'Artesano registrado exitosamente. Ahora puedes solicitar tu código de acceso.';
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'No se pudo completar el registro.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = ApiErrorHandler.parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // Registro: Administrador
  Future<bool> registrarAdministrador(AdministradorRequest request) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiClient.post(
        '/administradores',
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        _successMessage = 'Administrador registrado con éxito con nivel ${request.nivelAcceso}.';
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'No se pudo completar el registro.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = ApiErrorHandler.parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // Cambiar nivel de acceso de un administrador (solo Super Admin)
  Future<bool> cambiarNivelAccesoAdmin(String adminId, String nuevoNivel) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _apiClient.put(
        '/administradores/$adminId/nivel_acceso',
        data: {'nivelAcceso': nuevoNivel},
      );

      if (response.statusCode == 200) {
        _successMessage = 'Nivel de acceso actualizado exitosamente a $nuevoNivel.';
        if (_userSession != null && _userSession!.id == adminId) {
          _currentNivelAcceso = nuevoNivel;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_nivel_acceso', nuevoNivel);
        }
        _setLoading(false);
        return true;
      } else {
        _errorMessage = 'No se pudo actualizar el nivel de acceso.';
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _errorMessage = ApiErrorHandler.parseError(e);
      _setLoading(false);
      return false;
    }
  }

  // Cerrar sesión
  Future<void> logout() async {
    _userSession = null;
    _currentNivelAcceso = null;
    _currentStep = LoginStep.enterEmail;
    _emailSolicitado = '';
    _clearMessages();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_rol');
      await prefs.remove('auth_email');
      await prefs.remove('auth_user_id');
      await prefs.remove('auth_expiracion');
      await prefs.remove('auth_nivel_acceso');
    } catch (_) {}

    notifyListeners();
  }

  String? _extractUserIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final map = jsonDecode(payload) as Map<String, dynamic>;
        return map['id']?.toString();
      }
    } catch (_) {}
    return null;
  }

  String? _extractRolFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length >= 2) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final map = jsonDecode(payload) as Map<String, dynamic>;
        return map['rol']?.toString() ?? map['role']?.toString();
      }
    } catch (_) {}
    return null;
  }

  void resetLoginStep() {
    _currentStep = LoginStep.enterEmail;
    _clearMessages();
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}