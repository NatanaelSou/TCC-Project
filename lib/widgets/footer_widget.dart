import 'package:flutter/material.dart';
import '../constants.dart';

/// Widget para o rodapé/footer da landing page
class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: AppColors.primary,
      child: Column(
        children: [
          Text(
            '© 2025 ${AppStrings.appTitle}. Todos os direitos reservados.',
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Privacidade'),
              const SizedBox(width: 20),
              _buildFooterLink('Termos'),
              const SizedBox(width: 20),
              _buildFooterLink('Suporte'),
            ],
          ),
        ],
      ),
    );
  }

  // Link do footer
  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.textLight,
        fontSize: 14,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
