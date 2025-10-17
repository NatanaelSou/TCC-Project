import 'package:flutter/material.dart';

/// Gerenciador de filtros para a aplicação
/// Gerencia o estado dos filtros ativos e notifica mudanças na interface
class FilterManager extends ChangeNotifier {
  // Lista de filtros ativos
  List<String> _activeFilters = ['Todos'];

  // Lista de filtros disponíveis
  static const List<String> availableFilters = [
    'Todos',
    'Cultura pop',
    'Comédia',
    'Jogos de RPG',
    'Crimes reais',
    'Tutoriais de arte',
    'Artesanato',
    'Ilustração',
    'Música',
  ];

  /// Getter para filtros ativos
  List<String> get activeFilters => _activeFilters;

  /// Verifica se um filtro específico está ativo
  bool isFilterActive(String filter) => _activeFilters.contains(filter);

  /// Gerencia mudança de filtros (múltiplos filtros)
  void toggleFilter(String filter) {
    if (filter == 'Todos') {
      _activeFilters = ['Todos'];
    } else {
      _activeFilters.remove('Todos');

      if (_activeFilters.contains(filter)) {
        _activeFilters.remove(filter);
        if (_activeFilters.isEmpty) {
          _activeFilters = ['Todos'];
        }
      } else {
        _activeFilters.add(filter);
      }
    }
    notifyListeners();
  }

  /// Define filtros ativos diretamente
  void setActiveFilters(List<String> filters) {
    _activeFilters = List.from(filters);
    if (_activeFilters.isEmpty) {
      _activeFilters = ['Todos'];
    }
    notifyListeners();
  }

  /// Limpa todos os filtros (volta para 'Todos')
  void clearFilters() {
    _activeFilters = ['Todos'];
    notifyListeners();
  }

  /// Adiciona um filtro se não estiver ativo
  void addFilter(String filter) {
    if (!_activeFilters.contains(filter)) {
      if (filter == 'Todos') {
        _activeFilters = ['Todos'];
      } else {
        _activeFilters.remove('Todos');
        _activeFilters.add(filter);
      }
      notifyListeners();
    }
  }

  /// Remove um filtro se estiver ativo
  void removeFilter(String filter) {
    if (_activeFilters.contains(filter) && filter != 'Todos') {
      _activeFilters.remove(filter);
      if (_activeFilters.isEmpty) {
        _activeFilters = ['Todos'];
      }
      notifyListeners();
    }
  }
}
