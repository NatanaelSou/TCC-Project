// lib/presentation/screens/explore_page.dart
//
// Package Imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//
// Resources Imports
import '../../core/constants/constants.dart';
import '../../core/utils/filter_manager.dart';
import '../../core/utils/content_utils.dart';
import '../../data/mocks/mock_data.dart';
//
// Widgets Imports
import '../widgets/filter_tag.dart';
import '../widgets/creator_section.dart';
import '../widgets/content_section.dart';

/// Tela de exploração para descoberta de conteúdo por filtros
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
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
