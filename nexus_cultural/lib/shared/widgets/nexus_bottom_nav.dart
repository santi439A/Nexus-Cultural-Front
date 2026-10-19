import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';

class NexusBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final int cartCount;
  final int ordersBadge;
  final bool isArtisan; // Controla si se muestra el botón (+) Publicar

  const NexusBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.cartCount = 0,
    this.ordersBadge = 1,
    this.isArtisan = true, // Por defecto visible
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
            color: Colors.black.withOpacity(0.06),
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
              // 1. Inicio
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Inicio',
              ),
              // 2. Catálogo / Mi Catálogo
              _buildNavItem(
                context,
                index: 1,
                icon: isArtisan ? Icons.inventory_2_outlined : Icons.grid_view_outlined,
                selectedIcon: isArtisan ? Icons.inventory_2 : Icons.grid_view,
                label: isArtisan ? 'Mi catálogo' : 'Catálogo',
              ),
              // 3. Publicar FAB (Solo si es artesano)
              if (isArtisan) _buildCenterFab(context),
              // 4. Carrito
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.shopping_cart_outlined,
                selectedIcon: Icons.shopping_cart,
                label: 'Carrito',
                badgeCount: cartCount,
              ),
              // 5. Pedidos / Seguimiento
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.local_shipping_outlined,
                selectedIcon: Icons.local_shipping,
                label: 'Pedidos',
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
                  color: NexusColors.primary.withOpacity(0.35),
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