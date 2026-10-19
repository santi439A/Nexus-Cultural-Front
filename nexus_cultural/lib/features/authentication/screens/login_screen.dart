import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../../../config/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        setState(() => _resendCountdown = 0);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _onSolicitarOtp() async {
    if (!_emailFormKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.solicitarOtp(_emailController.text);

    if (mounted) {
      if (success) {
        _startCountdown();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.emeraldGreen,
            content: Text(authController.successMessage ?? 'Código OTP enviado al correo'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(authController.errorMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onVerificarOtp() async {
    if (!_otpFormKey.currentState!.validate()) return;

    final authController = context.read<AuthController>();
    final success = await authController.verificarOtp(
      _emailController.text.isNotEmpty ? _emailController.text : authController.emailSolicitado,
      _otpController.text,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.emeraldGreen,
            content: Text(authController.successMessage ?? 'Autenticación exitosa'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (authController.isAdmin) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home-admin', (route) => false);
        } else if (authController.isArtisan) {
          Navigator.of(context).pushNamedAndRemoveUntil('/home-artisan', (route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        }
      } else if (authController.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(authController.errorMessage!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isStepOtp = authController.currentStep == LoginStep.enterOtp;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (isStepOtp) {
              authController.resetLoginStep();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado Visual
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_outlined,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isStepOtp ? 'Verifica tu Código OTP' : 'Acceso por Correo',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isStepOtp
                    ? 'Hemos enviado un código de seguridad de 6 dígitos a:\n${authController.emailSolicitado}'
                    : 'Ingresa tu correo registrado para recibir tu código de acceso único.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // Banner de Error si existe
              if (authController.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authController.errorMessage!,
                          style: const TextStyle(color: AppColors.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Formulario Paso 1: Solicitar OTP
              if (!isStepOtp) ...[
                Form(
                  key: _emailFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu correo';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                            return 'Ingresa un correo electrónico válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: authController.isLoading ? null : _onSolicitarOtp,
                        child: authController.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Enviar Código de Acceso', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Formulario Paso 2: Ingresar Código OTP
                Form(
                  key: _otpFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: AppColors.primary,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Código OTP (6 dígitos)',
                          hintText: '123456',
                          counterText: '',
                          prefixIcon: Icon(Icons.password_rounded, color: AppColors.primary),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa el código OTP';
                          }
                          if (value.trim().length < 6) {
                            return 'El código debe tener 6 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),
                      ElevatedButton(
                        onPressed: authController.isLoading ? null : _onVerificarOtp,
                        child: authController.isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Verificar e Iniciar Sesión', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: Icon(_resendCountdown > 0 ? Icons.timer_outlined : Icons.refresh, size: 18),
                            label: Text(_resendCountdown > 0
                                ? 'Reenviar (${_resendCountdown}s)'
                                : 'Reenviar código'),
                            onPressed: (authController.isLoading || _resendCountdown > 0) ? null : _onSolicitarOtp,
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Cambiar correo'),
                            onPressed: authController.isLoading
                                ? null
                                : () => authController.resetLoginStep(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 36),
              // Enlace al registro si no tiene cuenta
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Aún no tienes cuenta? ', style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/register');
                    },
                    child: const Text(
                      'Regístrate aquí',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}