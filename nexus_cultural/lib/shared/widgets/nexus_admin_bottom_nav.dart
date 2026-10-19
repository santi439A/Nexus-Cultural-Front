import 'package:flutter/material.dart';
import '../../core/theme/nexus_theme.dart';

class NexusAdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final int pendingModerationCount;
  final int activeSupportCount;

  const NexusAdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.pendingModerationCount = 0,
    this.activeSupportCount = 0,
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
              // 0. Inicio / Dashboard
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: 'Inicio',
              ),
              // 1. Moderación
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.verified_user_outlined,
                selectedIcon: Icons.verified_user,
                label: 'Moderación',
                badgeCount: pendingModerationCount > 0 ? pendingModerationCount : null,
              ),
              // 2. Soporte
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.headset_mic_outlined,
                selectedIcon: Icons.headset_mic,
                label: 'Soporte',
                badgeCount: activeSupportCount > 0 ? activeSupportCount : null,
              ),
              // 3. Gestor Cultural
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.account_balance_outlined,
                selectedIcon: Icons.account_balance,
                label: 'Gestor',
              ),
              // 4. Equipo Admin
              _buildNavItem(
                context,
                index: 4,
                icon: Icons.admin_panel_settings_outlined,
                selectedIcon: Icons.admin_panel_settings,
                label: 'Equipo',
              ),
            ],
          ),
        ),
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
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badgeCount != null && badgeCount > 0,
                backgroundColor: NexusColors.goldAccent,
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
                  size: 26,
                  color: isSelected ? NexusColors.primary : NexusColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
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
