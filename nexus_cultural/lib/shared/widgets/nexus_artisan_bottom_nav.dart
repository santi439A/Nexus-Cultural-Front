import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';

class NexusArtisanBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final int ordersBadge;

  const NexusArtisanBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.ordersBadge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: NexusColors.borderLight, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 0. Inicio
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Inicio',
              ),
              // 1. Mi Catálogo
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2,
                label: 'Mi catálogo',
              ),
              // 2. FAB Central: Publicar
              _buildCenterFab(context),
              // 3. Estadísticas (Reemplaza al carrito)
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.bar_chart_outlined,
                selectedIcon: Icons.bar_chart,
                label: 'Estadísticas',
              ),
              // 4. Ventas recibidas
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                label: 'Ventas',
                badgeCount: ordersBadge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenterFab(BuildContext context) {
    final isSelected = currentIndex == 2;
    return GestureDetector(
      onTap: () => onTabSelected(2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isSelected ? NexusColors.primaryContainer : NexusColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: NexusColors.primary.withValues(alpha: 0.35),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Publicar',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? NexusColors.primary : NexusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: NexusAccessibility.minTouchTarget,
          minHeight: NexusAccessibility.minTouchTarget,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badgeCount != null && badgeCount > 0,
                backgroundColor: NexusColors.greenProtection,
                label: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: 28,
                  color: isSelected ? NexusColors.primary : NexusColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? NexusColors.primary : NexusColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}