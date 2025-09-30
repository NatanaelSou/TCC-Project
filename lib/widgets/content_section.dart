// lib/widgets/content_section.dart
//
// Widget que exibe uma seção de conteúdo (posts, vídeos, etc.)
// Mostra itens de conteúdo em layout de grid responsivo
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/profile_models.dart';

/// Seção de conteúdo com layout de grid
/// Exibe cards de conteúdo como posts, vídeos, etc.
class ContentSection extends StatelessWidget {
  // Propriedades
  final String title;
  final List<ProfileContent> contents;
  final bool showViewAll; // Mostrar botão "Ver tudo"

  const ContentSection({
    required this.title,
    required this.contents,
    this.showViewAll = true,
    super.key,
  });

  /// Constrói o cabeçalho da seção
  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        Spacer(),
        if (showViewAll)
          TextButton(
            onPressed: () {},
            child: Text(
              'Ver tudo',
              style: TextStyle(
                color: AppColors.btnSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  /// Constrói um card de conteúdo
  Widget _buildContentCard(ProfileContent content) {
    return Container(
      width: 280,
      margin: EdgeInsets.only(right: AppDimensions.spacingLarge, bottom: AppDimensions.spacingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContentThumbnail(content),
          _buildContentInfo(content),
        ],
      ),
    );
  }

  /// Constrói a thumbnail do conteúdo
  Widget _buildContentThumbnail(ProfileContent content) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.borderRadiusMedium)),
        image: DecorationImage(
          image: NetworkImage(content.thumbnailUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Overlay para tipo de conteúdo
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                content.type.toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Ícone de play para vídeos
          if (content.type == 'video')
            Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white.withOpacity(0.8),
                size: 48,
              ),
            ),
        ],
      ),
    );
  }

  /// Constrói as informações do conteúdo
  Widget _buildContentInfo(ProfileContent content) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 14,
                color: AppColors.textGrey,
              ),
              SizedBox(width: 4),
              Text(
                '${content.views} visualizações',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
              Spacer(),
              Text(
                _formatDate(content.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Formata a data para exibição
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d atrás';
    } else {
      return '${date.day}/${date.month}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: AppDimensions.spacingSmall),
        if (contents.isEmpty)
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            child: Center(
              child: Text(
                'Nenhum conteúdo encontrado para os filtros selecionados',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 16,
                ),
              ),
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: contents.map((content) => _buildContentCard(content)).toList(),
            ),
          ),
      ],
    );
  }
}
