import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import '../../../../core/theme/nexus_theme.dart';
import '../../../../services/app_state_providers.dart';
import '../../controllers/auth_controller.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class SmsOtpScreen extends ConsumerStatefulWidget {
  static const routeName = '/sms-otp';
  final String? email;
  final String? phone;

  const SmsOtpScreen({super.key, this.email, this.phone});

  @override
  ConsumerState<SmsOtpScreen> createState() => _SmsOtpScreenState();
}

class _SmsOtpScreenState extends ConsumerState<SmsOtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  int _resendCountdown = 30;
  Timer? _countdownTimer;

  String get _targetEmail {
    final raw = widget.email ?? widget.phone ?? '';
    if (raw.contains('@')) return raw.trim();
    if (raw.isNotEmpty) {
      return 'usuario_${raw.replaceAll(RegExp(r'\D'), '')}@nexuscultural.com';
    }
    return 'artesano@nexuscultural.com';
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

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
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Enfoca el primer campo vacío disponible
  void _focusFirstEmptyField() {
    for (int i = 0; i < _controllers.length; i++) {
      if (_controllers[i].text.isEmpty) {
        _focusNodes[i].requestFocus();
        return;
      }
    }
    _focusNodes.last.requestFocus();
  }

  Future<void> _verifyCode() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa los 6 dígitos del código de acceso.'),
          backgroundColor: NexusColors.error,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final emailToSend = _targetEmail;

    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: false);
      final ok = await authCtrl.verificarOtp(emailToSend, code);

      if (ok && mounted) {
        if (authCtrl.isAdmin) {
          ref.read(userRoleProvider.notifier).state = UserRole.admin;
          context.go('/home-admin');
        } else if (authCtrl.isArtisan) {
          ref.read(userRoleProvider.notifier).state = UserRole.artisan;
          context.go('/home-artisan');
        } else {
          ref.read(userRoleProvider.notifier).state = UserRole.buyer;
          context.go('/home');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.errorMessage ?? 'Código de verificación incorrecto o expirado.'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al conectar con el servidor. Intenta nuevamente.'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayEmail = _targetEmail;

    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Verificación de Acceso',
        subtitle: 'Código OTP sin Contraseñas',
        voiceExplanation:
            'Hemos enviado un código de 6 números a tu correo electrónico registrado. Escríbelo o pulsa el botón Verificar para ingresar.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner informativo

              VoiceAssistCard(
                title: 'Código enviado a tu correo',
                subtitle: displayEmail,
                textToRead:
                    'Código seguro de seis dígitos enviado a $displayEmail. Escribe los números para acceder.',
              ),

              const SizedBox(height: 20),
              const Text(
                'Ingresa los 6 dígitos recibidos:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: NexusColors.textPrimary),
              ),

              const SizedBox(height: 18),
              // 6 inputs numéricos con estado gris / activo y autofoco correlativo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  final hasValue = _controllers[index].text.isNotEmpty;
                  final isFocused = _focusNodes[index].hasFocus;

                  return SizedBox(
                    width: 48,
                    height: 64,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: NexusColors.primary,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        // Fondo gris si está vacío y no enfocado; blanco si está activo
                        fillColor: (hasValue || isFocused)
                            ? Colors.white
                            : Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: (hasValue || isFocused)
                                ? NexusColors.primary
                                : NexusColors.border,
                            width: (hasValue || isFocused) ? 2.0 : 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: hasValue
                                ? NexusColors.primary
                                : NexusColors.border,
                            width: hasValue ? 2.0 : 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: NexusColors.primary,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Al pulsar sobre cualquier casillero, dirige el foco al primer campo libre
                        _focusFirstEmptyField();
                      },
                      onChanged: (val) {
                        setState(() {}); // Actualiza el estilo visual
                        if (val.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),
              // Botón de confirmación con estado de carga
              ElevatedButton.icon(
                onPressed: _isVerifying ? null : _verifyCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.greenProtection,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.check_circle, size: 26),
                label: Text(
                  _isVerifying
                      ? 'Verificando...'
                      : 'Verificar Código y Entrar',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: (_isVerifying || _resendCountdown > 0)
                    ? null
                    : () async {
                        final emailToSend = _targetEmail;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Reenviando código OTP a $emailToSend...'),
                            backgroundColor: NexusColors.primary,
                          ),
                        );

                        try {
                          final authCtrl = p.Provider.of<AuthController>(
                              context,
                              listen: false);
                          await authCtrl.solicitarOtp(emailToSend);
                          _startCountdown();
                        } catch (_) {
                          _startCountdown();
                        }
                      },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: BorderSide(
                    color: _resendCountdown > 0
                        ? NexusColors.borderLight
                        : NexusColors.border,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: Icon(
                  _resendCountdown > 0 ? Icons.timer_outlined : Icons.refresh,
                  color: _resendCountdown > 0
                      ? NexusColors.textSecondary
                      : NexusColors.primary,
                ),
                label: Text(
                  _resendCountdown > 0
                      ? 'Reenviar código disponible en ${_resendCountdown}s'
                      : '¿No recibiste el código? Reenviar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _resendCountdown > 0
                        ? NexusColors.textSecondary
                        : NexusColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}