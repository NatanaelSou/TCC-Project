import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Widgets personalizados
import '../widgets/filter_tag.dart';
import '../widgets/creator_section.dart';
import '../widgets/content_section.dart';

// Serviços e Estado
import '../utils/filter_manager.dart';
import '../utils/content_utils.dart';
import '../constants.dart';
import '../mock_data.dart';
import '../models/profile_models.dart';

/// Tela de exploração para descoberta de conteúdo por filtros
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  /// Filtra conteúdos baseado nos filtros ativos
  List<ProfileContent> _filterContents(List<ProfileContent> contents, List<String> activeFilters) {
    if (activeFilters.isEmpty || activeFilters.contains('Todos')) {
      return contents;
    }
    return contents.where((content) =>
      content.category != null && activeFilters.contains(content.category!)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filterManager = Provider.of<FilterManager>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingExtraLarge,
        vertical: AppDimensions.spacingLarge,
      ),
      child: Column(
        children: [
          // Tags de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FilterManager.availableFilters.map((filter) => FilterTag(
                key: ValueKey(filter),
                label: filter,
                active: filterManager.isFilterActive(filter),
                onTap: () => filterManager.toggleFilter(filter),
              )).toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingExtraLarge),

          // Seção de criadores filtrados
          CreatorSection(
            title: 'Criadores encontrados',
            activeFilters: filterManager.activeFilters,
          ),
          const SizedBox(height: AppDimensions.spacingLarge),

          // Seções de conteúdo filtradas
          ContentSection(
            title: 'Posts',
            contents: ContentUtils.filterContents(mockRecentPosts, filterManager.activeFilters),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          ContentSection(
            title: 'Vídeos',
            contents: ContentUtils.filterContents(mockVideos, filterManager.activeFilters),
          ),
          const SizedBox(height: AppDimensions.spacingLarge),
          ContentSection(
            title: 'Conteúdo Exclusivo',
            contents: ContentUtils.filterContents(mockExclusiveContent, filterManager.activeFilters),
          ),
        ],
      ),
    );
  }
}
