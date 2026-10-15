import 'package:flutter/material.dart';
import '../../../config/theme/app_colors.dart';

class MainNexusScreen extends StatelessWidget {
  const MainNexusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),

              // Logo / Emblema Cultural
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.diversity_3_rounded,
                      size: 54,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Título y Eslogan
              const Text(
                'Nexus Cultural',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Conectando historias, artesanos y compradores en un solo ecosistema tradicional.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 3),

              // Botón Iniciar Sesión (OTP)
              ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded),
                label: const Text('Iniciar Sesión'),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              const SizedBox(height: 14),

              // Botón Registro (Comprador / Artesano / Admin)
              OutlinedButton.icon(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                label: const Text('Crear una Cuenta'),
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),

              const Spacer(flex: 1),

              // Pie de Página
              Center(
                child: Text(
                  'Artesanías y Tradición Colombiana',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}