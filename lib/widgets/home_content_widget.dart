import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';

import '../constants.dart';
import '../utils/filter_manager.dart';
import '../utils/content_utils.dart';
import '../mock_data.dart';
import '../models/profile_models.dart';
import 'filter_tag.dart';
import 'creator_section.dart';
import 'content_section.dart';

/// Widget para o conteúdo da página inicial com filtros e seções
class HomeContentWidget extends StatelessWidget {
  const HomeContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final filterManager = Provider.of<FilterManager>(context);

    // Função para filtrar conteúdos pela categoria selecionada
    List<ProfileContent> filterContents(List<ProfileContent> contents) {
      // Sempre mostrar tudo por padrão
      if (filterManager.activeFilters.isEmpty ||
          filterManager.isFilterActive('Todos')) {
        return contents;
      }
      return ContentUtils.filterContents(contents, filterManager.activeFilters);
    }

    // Função para verificar se um filtro está ativo
    bool isFilterActive(String filter) {
      return filterManager.isFilterActive(filter);
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingExtraLarge,
          vertical: AppDimensions.spacingLarge),
      child: Column(
        children: [
          // Tags de filtro
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.mouse,
                PointerDeviceKind.touch,
              },
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: Row(
                children: FilterManager.availableFilters
                    .map((filter) => FilterTag(
                          key: ValueKey(filter),
                          label: filter,
                          active: isFilterActive(filter),
                          onTap: () => filterManager.toggleFilter(filter),
                        ))
                    .toList(),
              ),
            ),
          ),

          SizedBox(height: AppDimensions.spacingExtraLarge),
          // Seções de criadores
          CreatorSection(
            title: 'Principais criadores',
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          ContentSection(
            title: 'Em alta esta semana',
            contents: filterContents([
              ...mockRecentPosts,
              ...mockVideos,
              ...mockExclusiveContent,
            ]),
          ),
          SizedBox(height: AppDimensions.spacingExtraLarge),
          // Seções de conteúdo filtradas
          ContentSection(
            title: 'Em alta',
            contents: filterContents(mockRecentPosts),
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          ContentSection(
            title: 'Vídeos',
            contents: filterContents(mockVideos),
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          ContentSection(
            title: 'Conteúdo Exclusivo',
            contents: filterContents(mockExclusiveContent),
          ),
          SizedBox(height: AppDimensions.spacingLarge),
          // Seção Ao vivo (placeholder)
          _buildLiveSection(),
        ],
      ),
    );
  }

  /// Constrói a seção Ao vivo (placeholder)
  Widget _buildLiveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ao vivo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            Spacer(),
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
        ),
        SizedBox(height: AppDimensions.spacingSmall),
        Container(
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          child: Center(
            child: Text(
              'Nenhuma transmissão ao vivo no momento',
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
