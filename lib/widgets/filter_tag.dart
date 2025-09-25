// lib/widgets/filter_tag.dart
//
// Widget que representa uma tag de filtro clicável
// Permite filtrar conteúdo por categoria com visual moderno
import 'package:flutter/material.dart';
import '../constants.dart';

/// Tag de filtro clicável para categorização de conteúdo
/// Suporta estados ativo/inativo com transições visuais suaves
class FilterTag extends StatelessWidget {
  // Propriedades
  final String label;
  final bool active;
  final VoidCallback? onTap;

  // Cores do widget
  static const Color _inactiveColor = Color(0xFFF0F0F0);

  // Construtor
  const FilterTag({
    required this.label,
    this.active = false,
    this.onTap,
    super.key,
  });

  /// Constrói o container da tag com estilos
  Widget _buildTagContainer() {
    return Container(
      margin: EdgeInsets.only(right: AppDimensions.spacingSmall),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLarge,
        vertical: AppDimensions.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: active ? AppColors.sidebarItemActive : _inactiveColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        border: Border.all(
          color: active ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: _buildTagContent(),
    );
  }

  /// Constrói o conteúdo da tag (texto)
  Widget _buildTagContent() {
    return Text(
      label,
      style: TextStyle(
        color: active ? AppColors.textLight : AppColors.textDark,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: AnimatedContainer(
          duration: AppDimensions.animationDuration,
          curve: Curves.easeInOut,
          child: _buildTagContainer(),
        ),
      ),
    );
  }
}
