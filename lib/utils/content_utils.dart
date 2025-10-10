import '../models/profile_models.dart';

/// Utilitários para manipulação de conteúdo
class ContentUtils {
  /// Filtra conteúdos baseado nos filtros ativos
  static List<ProfileContent> filterContents(
    List<ProfileContent> contents,
    List<String> activeFilters,
  ) {
    if (activeFilters.isEmpty || activeFilters.contains('Todos')) {
      return contents;
    }
    return contents.where((content) =>
      content.category != null && content.category!.any((cat) => activeFilters.contains(cat))
    ).toList();
  }
}
