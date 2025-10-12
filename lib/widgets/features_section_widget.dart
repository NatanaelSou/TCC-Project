import 'package:flutter/material.dart';
import '../constants.dart';

/// Widget para a seção de recursos/features da landing page
class FeaturesSectionWidget extends StatelessWidget {
  const FeaturesSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      {
        'icon': Icons.star,
        'title': 'Conteúdo\nExclusivo',
        'description': 'Acesse posts, vídeos e lives exclusivos dos seus criadores favoritos.',
      },
      {
        'icon': Icons.people,
        'title': 'Comunidade\nAtiva',
        'description': 'Interaja com outros fãs e criadores em chats e fóruns dedicados.',
      },
      {
        'icon': Icons.lock,
        'title': 'Pagamentos\nSeguros',
        'description': 'Assinaturas fáceis e seguras com múltiplas opções de pagamento.',
      },
      {
        'icon': Icons.devices,
        'title': 'Acesso em\nQualquer Lugar',
        'description': 'Desfrute do conteúdo no desktop, mobile ou qualquer dispositivo.',
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      color: AppColors.background,
      child: Column(
        children: [
          Text(
            'Por que escolher o ${AppStrings.appTitle}?',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: features.map((feature) => _buildFeatureCard(context, feature)).toList(),
                )
              : isTablet
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 40,
                      children: features.map((feature) => _buildFeatureCard(context, feature)).toList(),
                    )
                  : Column(
                      children: features.map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: _buildFeatureCard(context, feature),
                      )).toList(),
                    ),
        ],
      ),
    );
  }

  // Card de feature
  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

    return Container(
      width: isDesktop ? 250 : isTablet ? 200 : double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            feature['icon'] as IconData,
            size: 50,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 20),
          Text(
            feature['title'] as String,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            feature['description'] as String,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
