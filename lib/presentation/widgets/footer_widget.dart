// lib/presentation/widgets/footer_widget.dart
//
// Package Imports
import 'package:flutter/material.dart';

/// Widget para o rodapé/footer da landing page
class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: Colors.black,
      child: Column(
        children: [
          const Text(
            '© 2025 Premiora. Todos os direitos reservados.',
            style: TextStyle(
              color: Colors.white,
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        decoration: TextDecoration.underline,
      ),
    );
  }
}
