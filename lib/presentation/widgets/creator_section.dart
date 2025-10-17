// lib/presentation/widgets/creator_section.dart
//
// Package Imports
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
//
// Resources Imports
import '../../core/constants/constants.dart';

/// Seção de criadores com suporte a filtragem
/// Exibe cards de criadores em layout horizontal rolável
class CreatorSection extends StatefulWidget {
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

  
  @override
  State<CreatorSection> createState() => _CreatorSectionState();
}

class _CreatorSectionState extends State<CreatorSection> {
  final ScrollController _scrollController = ScrollController();

  /// Filtra os criadores baseado nos filtros ativos
  List<Map<String, dynamic>> get _filteredCreators {
    final data = widget.creators ?? CreatorSection._creatorsData;

    if (widget.activeFilters == null || widget.activeFilters!.isEmpty) {
      return data;
    }

    if (widget.activeFilters!.contains(AppStrings.filterAll)) {
      return data;
    }

    return data.where((creator) {
      return widget.activeFilters!.contains(creator['category']);
    }).toList();
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Constrói o cabeçalho da seção
  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        Spacer(),
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.offset - 300,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
          color: AppColors.iconDark,
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: () {
            _scrollController.animateTo(
              _scrollController.offset + 300,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          },
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
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadiusMedium)),
        color: (creator['imageColor'] is Color)
            ? creator['imageColor'] as Color
            : Colors.grey,
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
            creator['name'] ?? 'Nome desconhecido',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            creator['description'] ?? 'Sem descrição',
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
        // ScrollConfiguration deve envolver o SingleChildScrollView
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: SingleChildScrollView(
            controller: _scrollController, // use _scrollController
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(), // melhor para desktop/web
            child: Row(
              children: filteredCreators
                  .map((creator) => _buildCreatorCard(creator))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}