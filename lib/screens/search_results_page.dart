import 'package:flutter/material.dart';

// Widgets personalizados
import '../widgets/creator_section.dart';
import '../widgets/content_section.dart';

// Serviços e Estado
import '../services/api_service.dart';
import '../constants.dart';
import '../models/profile_models.dart';

/// Página de resultados de busca
/// Exibe criadores e conteúdos filtrados por keywords
class SearchResultsPage extends StatefulWidget {
  final String query;

  const SearchResultsPage({super.key, required this.query});

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _creators = [];
  List<ProfileContent> _contents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _performSearch();
  }

  /// Executa a busca por criadores e conteúdos
  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    try {
      final creators = await _apiService.searchCreators(widget.query);
      final contents = await _apiService.searchContents(widget.query);

      setState(() {
        _creators = creators;
        _contents = contents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Em caso de erro, mostra listas vazias
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados para "${widget.query}"'),
        backgroundColor: AppColors.sidebar,
        foregroundColor: AppColors.iconDark,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.iconDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingExtraLarge,
                vertical: AppDimensions.spacingLarge,
              ),
              child: Column(
                children: [
                  // Seção de criadores encontrados
                  if (_creators.isNotEmpty)
                    CreatorSection(
                      title: 'Criadores encontrados',
                      creators: _creators,
                    ),
                  if (_creators.isNotEmpty)
                    const SizedBox(height: AppDimensions.spacingLarge),

                  // Seção de conteúdos encontrados
                  if (_contents.isNotEmpty)
                    ContentSection(
                      title: 'Conteúdos encontrados',
                      contents: _contents,
                      showViewAll: false,
                    ),

                  // Mensagem quando não há resultados
                  if (_creators.isEmpty && _contents.isEmpty)
                    SizedBox(
                      height: 200,
                      child: Center(
                        child: Text(
                          'Nenhum resultado encontrado para "${widget.query}"',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
