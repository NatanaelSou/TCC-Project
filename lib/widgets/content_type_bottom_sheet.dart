import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../constants.dart';

/// Bottom sheet para seleção do tipo de conteúdo a ser criado
class ContentTypeBottomSheet extends StatelessWidget {
  final Function(ContentType) onTypeSelected;

  const ContentTypeBottomSheet({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título do bottom sheet
          Text(
            'Escolher tipo de conteúdo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: AppDimensions.spacingLarge),

          // Lista de tipos de conteúdo
          ...ContentType.values.map((type) => _buildTypeButton(context, type)),

          SizedBox(height: AppDimensions.spacingSmall),
        ],
      ),
    );
  }

  /// Constrói botão para um tipo de conteúdo específico
  Widget _buildTypeButton(BuildContext context, ContentType type) {
    // Mapeia o tipo para ícone e texto
    final typeData = _getTypeData(type);

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop(); // Fecha o bottom sheet
          onTypeSelected(type); // Chama o callback com o tipo selecionado
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cardBg,
          foregroundColor: AppColors.textDark,
          padding: EdgeInsets.all(AppDimensions.spacingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          elevation: 0,
        ),
        child: Row(
          children: [
            Icon(typeData['icon'], size: 24),
            SizedBox(width: AppDimensions.spacingMedium),
            Expanded(
              child: Text(
                typeData['label'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna dados do tipo (ícone e label)
  Map<String, dynamic> _getTypeData(ContentType type) {
    switch (type) {
      case ContentType.post:
        return {
          'icon': Icons.article,
          'label': 'Post',
        };
      case ContentType.video:
        return {
          'icon': Icons.video_library,
          'label': 'Vídeo',
        };
      case ContentType.live:
        return {
          'icon': Icons.live_tv,
          'label': 'Transmissão ao vivo',
        };
      case ContentType.podcast:
        return {
          'icon': Icons.mic,
          'label': 'Podcast',
        };
      case ContentType.course:
        return {
          'icon': Icons.school,
          'label': 'Curso',
        };
      case ContentType.other:
        return {
          'icon': Icons.more_horiz,
          'label': 'Outro',
        };
    }
  }
}
