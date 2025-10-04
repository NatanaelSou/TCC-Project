import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_models.dart';
import '../services/content_service.dart';
import '../constants.dart';
import '../user_state.dart';
import '../mock_data.dart';
import '../utils/filter_manager.dart';
import '../widgets/file_picker_widget.dart';

/// Página para criação de novo conteúdo
class ContentCreationPage extends StatefulWidget {
  final ContentType contentType;

  const ContentCreationPage({
    super.key,
    required this.contentType,
  });

  @override
  State<ContentCreationPage> createState() => _ContentCreationPageState();
}

class _ContentCreationPageState extends State<ContentCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _contentService = ContentService();

  // Controladores dos campos
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordsController = TextEditingController();

  // Estados dos arquivos selecionados
  String? _selectedThumbnailPath;
  String? _selectedImagePath;
  String? _selectedVideoPath;

  // Estados dos switches e dropdowns
  final List<String> _selectedCategories = [];
  bool _is18Plus = false;
  bool _isPrivate = false;
  String? _selectedQuality;
  String? _selectedTier;

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  /// Submete o formulário para criar o conteúdo
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validação adicional para campos obrigatórios de arquivo
    if (widget.contentType == ContentType.video && _selectedVideoPath == null) {
      _showErrorSnackBar('Vídeo é obrigatório para conteúdo de vídeo');
      return;
    }

    // Obtém o creatorId e navigator antes de qualquer operação assíncrona
    final userState = Provider.of<UserState>(context, listen: false);
    final creatorId = userState.user?.id?.toString() ?? '1';
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      // Coleta os dados do formulário
      final data = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': widget.contentType.name,
        'thumbnailUrl': _selectedThumbnailPath ?? '',
        'videoUrl': _selectedVideoPath ?? '',
        'category': _selectedCategories.isEmpty ? null : _selectedCategories,
        'keywords': _keywordsController.text.isNotEmpty
            ? _keywordsController.text.split(',').map((k) => k.trim()).toList()
            : null,
        'is18Plus': _is18Plus,
        'isPrivate': _isPrivate,
        'quality': _selectedQuality,
        'images': _selectedImagePath != null ? [_selectedImagePath] : null,
        'tierRequired': _selectedTier,
        'creatorId': creatorId,
      };

      // Cria o conteúdo
      final content = await _contentService.createContent(creatorId, data);

      if (!mounted) return;

      if (content != null) {
        // Retorna o conteúdo criado para a página anterior usando o navigator capturado
        navigator.pop(content);
      } else {
        _showErrorSnackBar('Erro ao criar conteúdo. Tente novamente.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Erro inesperado: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Mostra snackbar de erro
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.sidebar,
        foregroundColor: AppColors.iconDark,
        title: Text('Criar ${widget.contentType.name}'),
        actions: [
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(AppDimensions.spacingSmall),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.iconDark),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitForm,
              child: Text(
                'Publicar',
                style: TextStyle(
                  color: AppColors.btnSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.spacingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo título
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título *',
                  hintText: 'Digite o título do conteúdo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Título é obrigatório';
                  }
                  if (value.length > 200) {
                    return 'Título deve ter no máximo 200 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingLarge),

              // Campo descrição
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descrição *',
                  hintText: 'Descreva o conteúdo em detalhes',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Descrição é obrigatória';
                  }
                  if (value.length > 1000) {
                    return 'Descrição deve ter no máximo 1000 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingLarge),

              // Campo palavras-chave
              TextFormField(
                controller: _keywordsController,
                decoration: InputDecoration(
                  labelText: 'Palavras-chave',
                  hintText: 'Separe por vírgula (máx. 10)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final keywords = value.split(',').map((k) => k.trim()).where((k) => k.isNotEmpty).toList();
                    if (keywords.length > 10) {
                      return 'Máximo de 10 palavras-chave';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: AppDimensions.spacingLarge),

              // Seleção de categorias
              Text(
                'Categorias',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              SizedBox(height: AppDimensions.spacingSmall),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: FilterManager.availableFilters.map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _selectedCategories.contains(filter),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategories.add(filter);
                        } else {
                          _selectedCategories.remove(filter);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: AppDimensions.spacingLarge),

              // Switches para 18+ e privado
              SwitchListTile(
                title: Text('Conteúdo +18'),
                subtitle: Text('Marcar se o conteúdo é para maiores de 18 anos'),
                value: _is18Plus,
                onChanged: (value) => setState(() => _is18Plus = value),
              ),
              SwitchListTile(
                title: Text('Conteúdo privado'),
                subtitle: Text('Apenas para assinantes'),
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
              ),

              // Campo thumbnail se for vídeo ou live
              if (widget.contentType == ContentType.video || widget.contentType == ContentType.live)
                Column(
                  children: [
                    SizedBox(height: AppDimensions.spacingLarge),
                    FilePickerWidget(
                      label: 'Thumbnail',
                      hint: 'Selecione uma imagem para thumbnail',
                      selectedFilePath: _selectedThumbnailPath,
                      onFileSelected: (path) => setState(() => _selectedThumbnailPath = path),
                      isVideo: false,
                      isRequired: false,
                    ),
                  ],
                ),

              // Campo vídeo se for vídeo
              if (widget.contentType == ContentType.video)
                Column(
                  children: [
                    SizedBox(height: AppDimensions.spacingLarge),
                    FilePickerWidget(
                      label: 'Vídeo',
                      hint: 'Selecione um arquivo de vídeo',
                      selectedFilePath: _selectedVideoPath,
                      onFileSelected: (path) => setState(() => _selectedVideoPath = path),
                      isVideo: true,
                      isRequired: true,
                    ),
                  ],
                ),

              // Dropdown qualidade se for vídeo ou live
              if (widget.contentType == ContentType.video || widget.contentType == ContentType.live)
                Column(
                  children: [
                    SizedBox(height: AppDimensions.spacingLarge),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedQuality,
                      decoration: InputDecoration(
                        labelText: 'Qualidade',
                        border: OutlineInputBorder(),
                      ),
                      items: ['low', 'medium', 'high'].map((quality) {
                        return DropdownMenuItem(
                          value: quality,
                          child: Text(quality == 'low' ? 'Baixa' : quality == 'medium' ? 'Média' : 'Alta'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedQuality = value),
                    ),
                  ],
                ),

              // Campo imagem se for post
              if (widget.contentType == ContentType.post)
                Column(
                  children: [
                    SizedBox(height: AppDimensions.spacingLarge),
                    FilePickerWidget(
                      label: 'Imagem',
                      hint: 'Selecione uma imagem',
                      selectedFilePath: _selectedImagePath,
                      onFileSelected: (path) => setState(() => _selectedImagePath = path),
                      isVideo: false,
                      isRequired: false,
                    ),
                  ],
                ),

              // Dropdown tier se for privado
              if (_isPrivate)
                Column(
                  children: [
                    SizedBox(height: AppDimensions.spacingLarge),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTier,
                      decoration: InputDecoration(
                        labelText: 'Tier necessário *',
                        border: OutlineInputBorder(),
                      ),
                      items: mockSupportTiers.map((tier) {
                        return DropdownMenuItem(
                          value: tier.id,
                          child: Text('${tier.name} - R\$ ${tier.price.toStringAsFixed(0)}/mês'),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedTier = value),
                      validator: (value) {
                        if (_isPrivate && (value == null || value.isEmpty)) {
                          return 'Selecione um tier para conteúdo privado';
                        }
                        return null;
                      },
                    ),
                  ],
                ),

              SizedBox(height: AppDimensions.spacingExtraLarge),
            ],
          ),
        ),
      ),
    );
  }
}
