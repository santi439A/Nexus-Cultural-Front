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

  AuthController() {
    checkCurrentSession();
  }

  // Verifica si hay una sesión activa guardada
  Future<void> checkCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('auth_email');
      final rol = prefs.getString('auth_rol');
      final expiracion = prefs.getInt('auth_expiracion') ?? 0;

      if (token != null && token.isNotEmpty && email != null && rol != null) {
        _userSession = UserSession(
          email: email,
          token: token,
          rol: rol,
          expiracionEnSegundos: expiracion,
        );
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

      // Guardar en sesión
      _userSession = UserSession(
        email: email.trim(),
        token: authResponse.token,
        rol: authResponse.rol,
        expiracionEnSegundos: authResponse.expiracionEnSegundos,
      );

      // Persistir token en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', authResponse.token);
      await prefs.setString('auth_rol', authResponse.rol);
      await prefs.setString('auth_email', email.trim());
      await prefs.setInt('auth_expiracion', authResponse.expiracionEnSegundos);

      _successMessage = '¡Bienvenido! Sesión iniciada con rol: ${authResponse.rol}';
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

  // Cerrar sesión
  Future<void> logout() async {
    _userSession = null;
    _currentStep = LoginStep.enterEmail;
    _emailSolicitado = '';
    _clearMessages();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_rol');
      await prefs.remove('auth_email');
      await prefs.remove('auth_expiracion');
    } catch (_) {}

    notifyListeners();
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