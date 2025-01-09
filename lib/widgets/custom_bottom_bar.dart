// lib/widgets/custom_bottom_bar.dart
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  void _navigateToScreen(BuildContext context, String routeName) {
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    String currentRoute = ModalRoute.of(context)?.settings.name ?? '/historial';

    return Container(
      height: 80, // Altura fija para la barra
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              context: context,
              icon: Icons.home,
              label: 'Home',
              routeName: '/Home',
              isSelected: currentRoute == '/Home',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.account_balance_wallet_rounded,
              label: 'Ganancias',
              routeName: '/order',
              isSelected: currentRoute == '/order',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.support_agent_rounded,
              label: 'Soporte',
              routeName: '/soporte',
              isSelected: currentRoute == '/soporte',
            ),
            _buildNavItem(
              context: context,
              icon: Icons.person_rounded,
              label: 'Perfil',
              routeName: '/perfil',
              isSelected: currentRoute == '/perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String routeName,
    required bool isSelected,
  }) {
    // Ancho fijo para cada botón
    return SizedBox(
      width: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToScreen(context, routeName),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppColors.active : AppColors.inactive,
                  size: 28, // Tamaño fijo para los iconos
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? AppColors.active : AppColors.inactive,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}