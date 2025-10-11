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
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Premiora',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Botão outlined
  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.black),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black),
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
