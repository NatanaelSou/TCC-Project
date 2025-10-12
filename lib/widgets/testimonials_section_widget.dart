import 'package:flutter/material.dart';
import '../constants.dart';

/// Widget para a seção de depoimentos/testimonials da landing page
class TestimonialsSectionWidget extends StatelessWidget {
  const TestimonialsSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final testimonials = [
      {
        'text': 'Incrível plataforma! Encontrei criadores incríveis e o conteúdo é de alta qualidade.',
        'author': 'João Silva, Assinante',
      },
      {
        'text': 'Como criador, adorei a facilidade de monetizar meu trabalho e interagir com fãs.',
        'author': 'Maria Santos, Criadora',
      },
      {
        'text': 'A comunidade é engajada e os pagamentos são super rápidos. Recomendo!',
        'author': 'Carlos Oliveira, Assinante',
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
      child: Column(
        children: [
          Text(
            'O que nossos usuários dizem sobre o ${AppStrings.appTitle}',
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
                  children: testimonials.map((testimonial) => _buildTestimonialCard(context, testimonial)).toList(),
                )
              : isTablet
                  ? Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 40,
                      children: testimonials.map((testimonial) => _buildTestimonialCard(context, testimonial)).toList(),
                    )
                  : Column(
                      children: testimonials.map((testimonial) => Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: _buildTestimonialCard(context, testimonial),
                      )).toList(),
                    ),
        ],
      ),
    );
  }

  // Card de depoimento
  Widget _buildTestimonialCard(BuildContext context, Map<String, dynamic> testimonial) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768;

    return Container(
      width: isDesktop ? 300 : isTablet ? 250 : double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            '"${testimonial['text']}"',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textGrey,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            testimonial['author'] as String,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
