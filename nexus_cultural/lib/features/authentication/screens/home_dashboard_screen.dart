import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../authentication/controllers/auth_controller.dart';
import '../../../config/theme/app_colors.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final session = authController.userSession;
    final role = session?.rol ?? 'COMPRADOR';
    final email = session?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nexus Cultural'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar Sesión',
            onPressed: () async {
              await authController.logout();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner de Bienvenida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const Icon(Icons.verified, color: Colors.white70, size: 24),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¡Sesión iniciada con éxito!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Contenido según el Rol
              Text(
                'Panel de $role',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              if (role.toUpperCase() == 'COMPRADOR') ...[
                _buildOptionCard(
                  icon: Icons.storefront_outlined,
                  title: 'Explorar Catálogo',
                  subtitle: 'Descubre artesanías auténticas de nuestros creadores.',
                  color: AppColors.primary,
                  onTap: () {},
                ),
                _buildOptionCard(
                  icon: Icons.favorite_border_rounded,
                  title: 'Mis Favoritos',
                  subtitle: 'Revisa las piezas culturales que has guardado.',
                  color: AppColors.accentWarm,
                  onTap: () {},
                ),
                _buildOptionCard(
                  icon: Icons.local_shipping_outlined,
                  title: 'Mis Pedidos',
                  subtitle: 'Rastrea el estado de tus compras de artesanía.',
                  color: AppColors.emeraldGreen,
                  onTap: () {},
                ),
              ] else if (role.toUpperCase() == 'ARTESANO') ...[
                _buildOptionCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Gestionar Mis Obras',
                  subtitle: 'Publica y actualiza tus creaciones culturales.',
                  color: AppColors.primary,
                  onTap: () {},
                ),
                _buildOptionCard(
                  icon: Icons.receipt_long_outlined,
                  title: 'Pedidos Recibidos',
                  subtitle: 'Revisa solicitudes de compradores interesados.',
                  color: AppColors.accentWarm,
                  onTap: () {},
                ),
                _buildOptionCard(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Mi Trayectoria Cultural',
                  subtitle: 'Gestiona tu experiencia y reconocimientos.',
                  color: AppColors.emeraldGreen,
                  onTap: () {},
                ),
              ] else ...[
                _buildOptionCard(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'Gestión de Usuarios y Roles',
                  subtitle: 'Control de accesos y administración general.',
                  color: AppColors.primary,
                  onTap: () {},
                ),
                _buildOptionCard(
                  icon: Icons.analytics_outlined,
                  title: 'Métricas de la Plataforma',
                  subtitle: 'Estadísticas de ventas, pedidos y registros.',
                  color: AppColors.accentWarm,
                  onTap: () {},
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
