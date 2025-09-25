// lib/widgets/sidebar_item.dart
//
// Widgets para itens da barra lateral
// Inclui itens de navegação e prompt para criadores
import 'package:flutter/material.dart';
import '../constants.dart';

/// Item de navegação da sidebar
/// Suporta modo expandido e retraído com visual consistente
class SidebarItem extends StatelessWidget {
  // Propriedades
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final bool expanded;

  // Construtor
  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
    this.expanded = true,
  });

  /// Constrói o item no modo expandido
  Widget _buildExpandedItem() {
    return ListTile(
      leading: Icon(
        icon,
        color: active ? AppColors.textLight : AppColors.textDark,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.textLight : AppColors.textDark,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: AppDimensions.spacingSmall,
      minLeadingWidth: 32,
      contentPadding: EdgeInsets.symmetric(horizontal: AppDimensions.spacingMedium),
    );
  }

  /// Constrói o item no modo retraído
  Widget _buildCollapsedItem() {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      child: Container(
        height: 48,
        width: double.infinity,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: active ? AppColors.textLight : AppColors.textDark,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      decoration: BoxDecoration(
        color: active ? AppColors.sidebarItemActive : Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusSmall),
      ),
      child: expanded ? _buildExpandedItem() : _buildCollapsedItem(),
    );
  }
}

/// Prompt para incentivar usuário a se tornar criador
/// Adapta o conteúdo baseado no estado expandido/retraído da sidebar
class SidebarPrompt extends StatelessWidget {
  // Propriedades
  final VoidCallback? onPressed;
  final bool expanded;
  final VoidCallback? onClose;

  // Textos do prompt
  static const String _title = 'Seja um criador';
  static const String _expandedDescription =
      'Crie uma assinatura para seus fãs e receba para criar da forma que quiser.';
  static const String _collapsedButtonText = 'Criar';
  static const String _expandedButtonText = 'Comece agora mesmo';

  // Construtor
  const SidebarPrompt({
    super.key,
    this.onPressed,
    this.expanded = true,
    this.onClose,
  });

  /// Constrói o cabeçalho do prompt (apenas no modo expandido)
  Widget? _buildHeader() {
    if (!expanded) return null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: Icon(Icons.close),
          onPressed: onClose ?? () {},
        ),
      ],
    );
  }

  /// Constrói a descrição do prompt
  Widget _buildDescription() {
    return Text(
      expanded ? _expandedDescription : '',
      style: TextStyle(fontSize: 12),
    );
  }

  /// Constrói o botão de ação
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.btnSecondary,
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: onPressed,
        child: Text(
          expanded ? _expandedButtonText : _collapsedButtonText,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingLarge),
      decoration: BoxDecoration(
        color: AppColors.sidebarPromptBg,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppColors.sidebarPromptShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_buildHeader() != null) _buildHeader()!,
          if (expanded) SizedBox(height: AppDimensions.spacingSmall),
          _buildDescription(),
          SizedBox(height: expanded ? AppDimensions.spacingMedium : 0),
          _buildActionButton(),
        ],
      ),
    );
  }
}
