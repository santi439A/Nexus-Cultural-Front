import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as p;
import '../../../../core/theme/nexus_theme.dart';
import '../../controllers/auth_controller.dart';
import '../../../../shared/widgets/nexus_app_bar.dart';
import '../../../../shared/widgets/voice_assist_card.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor escribe tu correo electrónico registrado.'),
          backgroundColor: NexusColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authCtrl = p.Provider.of<AuthController>(context, listen: false);
      final ok = await authCtrl.solicitarOtp(email);

      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.successMessage ?? 'Código enviado con éxito a tu correo.'),
            backgroundColor: NexusColors.greenProtection,
          ),
        );
        context.push('/sms-otp', extra: email);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authCtrl.errorMessage ?? 'No se pudo enviar el código. Verifica tu correo.'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión. Intenta de nuevo.'),
            backgroundColor: NexusColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NexusAppBar(
        title: 'Ingreso Seguro',
        subtitle: 'Acceso sin contraseñas difíciles',
        voiceExplanation:
            'Ingreso a Nexus Cultural. Escribe tu correo electrónico registrado y pulsa el botón Recibir Código para entrar sin recordar contraseñas.',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner M06

              const VoiceAssistCard(
                title: 'Lectura guiada de ingreso',
                subtitle: 'Ingreso rápido y seguro',
                textToRead:
                    'Para entrar de manera segura, escribe tu correo electrónico registrado y te enviaremos un código de verificación.',
              ),

              const SizedBox(height: 24),
              // Big Emblem
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: NexusColors.surfaceHighlight,
                    shape: BoxShape.circle,
                    border: Border.all(color: NexusColors.primary, width: 2.5),
                  ),
                  child: const Center(
                    child: Icon(Icons.email, size: 48, color: NexusColors.primary),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Correo Electrónico Registrado',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: NexusColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Ej: maria@correo.com',
                  prefixIcon: Icon(Icons.email, color: NexusColors.primary),
                ),
              ),

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _requestOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexusColors.primary,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(NexusAccessibility.borderRadius),
                  ),
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send, size: 24),
                label: Text(
                  _isLoading ? 'Enviando...' : 'Recibir Código de Verificación',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  context.push('/role-selection');
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Text(
                  '¿Aún no tienes cuenta? Regístrate aquí',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: NexusColors.primary,
                    decoration: TextDecoration.underline,
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
