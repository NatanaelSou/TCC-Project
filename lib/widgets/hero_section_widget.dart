import 'package:flutter/material.dart';
import '../constants.dart';

/// Widget para a seção hero responsiva da landing page
class HeroSectionWidget extends StatelessWidget {
  final VoidCallback onStartPressed;
  final VoidCallback onLoginPressed;

  const HeroSectionWidget({
    super.key,
    required this.onStartPressed,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

    final titleFontSize = isDesktop ? 48.0 : isTablet ? 36.0 : 28.0;
    final descFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
      child: isTablet
          ? Row(
              children: [
                // Conteúdo da esquerda
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conteúdo Premium\npara Criadores e Fãs',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Descubra e apoie seus criadores favoritos com assinaturas exclusivas. Acesse conteúdo único, interaja na comunidade e seja parte de algo especial.',
                        style: TextStyle(
                          fontSize: descFontSize,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          _buildFilledButton('Comece Agora', onStartPressed),
                          const SizedBox(width: 15),
                          _buildOutlinedButton('Já tenho conta', onLoginPressed),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                // Imagem Hero
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Imagem Hero',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                // Imagem Hero para mobile
                Container(
                  height: 250,
                  margin: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Text(
                      'Imagem Hero',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                // Conteúdo para mobile
                Text(
                  'Conteúdo Premium\npara Criadores e Fãs',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  'Descubra e apoie seus criadores favoritos com assinaturas exclusivas. Acesse conteúdo único, interaja na comunidade e seja parte de algo especial.',
                  style: TextStyle(
                    fontSize: descFontSize,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    _buildFilledButton('Comece Agora', onStartPressed),
                    const SizedBox(height: 15),
                    _buildOutlinedButton('Já tenho conta', onLoginPressed),
                  ],
                ),
              ],
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
}
