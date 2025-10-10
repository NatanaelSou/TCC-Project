// lib/widgets/creator_section.dart
//
// Widget que exibe uma seção de criadores com suporte a filtragem múltipla
// Permite filtrar criadores por múltiplas categorias simultaneamente
import 'package:flutter/material.dart';
import '../constants.dart';

/// Seção de criadores com suporte a filtragem
/// Exibe cards de criadores em layout horizontal rolável
class CreatorSection extends StatelessWidget {
  // Propriedades
  final String title;
  final List<String>? activeFilters;

  // Dados mockados dos criadores
  static const List<Map<String, dynamic>> _creatorsData = [
    {
      'name': 'João Silva',
      'category': 'Cultura pop',
      'description': 'Especialista em filmes e séries',
      'imageColor': Color(0xFF90CAF9),
    },
    {
      'name': 'Maria Santos',
      'category': 'Comédia',
      'description': 'Conteúdo humorístico diário',
      'imageColor': Color(0xFFFFCC80),
    },
    {
      'name': 'Pedro Costa',
      'category': 'Jogos de RPG',
      'description': 'Dicas e gameplays de RPG',
      'imageColor': Color(0xFFA5D6A7),
    },
    {
      'name': 'Ana Oliveira',
      'category': 'Crimes reais',
      'description': 'Análise de casos famosos',
      'imageColor': Color(0xFFEF9A9A),
    },
    {
      'name': 'Carlos Mendes',
      'category': 'Tutoriais de arte',
      'description': 'Aulas de desenho digital',
      'imageColor': Color(0xFFCE93D8),
    },
    {
      'name': 'Beatriz Lima',
      'category': 'Artesanato',
      'description': 'DIY e trabalhos manuais',
      'imageColor': Color(0xFFF8BBD9),
    },
    {
      'name': 'Rafael Dias',
      'category': 'Ilustração',
      'description': 'Arte digital e tradicional',
      'imageColor': Color(0xFF80CBC4),
    },
    {
      'name': 'Fernanda Rocha',
      'category': 'Música',
      'description': 'Reviews e análises musicais',
      'imageColor': Color(0xFF9FA8DA),
    },
  ];

  final List<Map<String, dynamic>>? creators;

  const CreatorSection({
    required this.title,
    this.activeFilters,
    this.creators,
    super.key,
  });

  /// Filtra os criadores baseado nos filtros ativos
  List<Map<String, dynamic>> get _filteredCreators {
    final data = creators ?? _creatorsData;

    if (activeFilters == null || activeFilters!.isEmpty) {
      return data;
    }

    if (activeFilters!.contains(AppStrings.filterAll)) {
      return data;
    }

    return data.where((creator) {
      return activeFilters!.contains(creator['category']);
    }).toList();
  }

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
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {},
          color: AppColors.iconDark,
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {},
          color: AppColors.iconDark,
        ),
      ],
    );
  }

  /// Constrói um card de criador
  Widget _buildCreatorCard(Map<String, dynamic> creator) {
    return Container(
      width: AppDimensions.creatorCardWidth,
      margin: EdgeInsets.only(right: AppDimensions.spacingLarge),
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
          _buildCreatorImage(creator),
          _buildCreatorInfo(creator),
        ],
      ),
    );
  }

  /// Constrói a área da imagem do criador
  Widget _buildCreatorImage(Map<String, dynamic> creator) {
    return Container(
      height: AppDimensions.creatorCardImageHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.borderRadiusMedium)),
        color: creator['imageColor'] as Color,
      ),
    );
  }

  /// Constrói as informações do criador
  Widget _buildCreatorInfo(Map<String, dynamic> creator) {
    return Padding(
      padding: EdgeInsets.all(AppDimensions.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            creator['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            creator['description'],
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredCreators = _filteredCreators;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        SizedBox(height: AppDimensions.spacingSmall),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filteredCreators.map((creator) => _buildCreatorCard(creator)).toList(),
          ),
        ),
      ],
    );
  }
}
