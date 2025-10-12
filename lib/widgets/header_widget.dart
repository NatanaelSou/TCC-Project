import 'package:flutter/material.dart';
import '../constants.dart';

/// Widget para o cabeçalho da landing page com logo e navegação
class HeaderWidget extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final VoidCallback onRegisterPressed;

  const HeaderWidget({
    super.key,
    required this.onLoginPressed,
    required this.onRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Icon(
                Icons.volunteer_activism,
                color: AppColors.secondary,
                size: 32,
              ),
              const SizedBox(width: 8),
              Text(
                AppStrings.appTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Navegação desktop
          MediaQuery.of(context).size.width > 768
              ? Row(
                  children: [
                    _buildNavItem('Recursos'),
                    _buildNavItem('Depoimentos'),
                    _buildNavItem('Contato'),
                    const SizedBox(width: 20),
                    _buildOutlinedButton('Entrar', onLoginPressed),
                    const SizedBox(width: 10),
                    _buildFilledButton('Registrar-se', onRegisterPressed),
                  ],
                )
              : IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                ),
        ],
      ),
    );
  }

  // Item de navegação
  Widget _buildNavItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  // Botão outlined
  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.secondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: TextStyle(color: AppColors.textDark),
      ),
    );
  }

  // Botão filled
  Widget _buildFilledButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.btnSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
