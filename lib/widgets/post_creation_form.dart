import 'package:flutter/material.dart';
import '../models/profile_models.dart';
import '../constants.dart';
import '../mock_data.dart';
import '../utils/filter_manager.dart';
import 'file_picker_widget.dart';

/// Widget para formulário de criação de posts estilo Reddit
class PostCreationForm extends StatefulWidget {
  final ContentType contentType;
  final Function(Map<String, dynamic>) onSubmit;
  final bool isLoading;

  const PostCreationForm({
    super.key,
    required this.contentType,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<PostCreationForm> createState() => _PostCreationFormState();
}

class _PostCreationFormState extends State<PostCreationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordsController = TextEditingController();

  // Estados
  String? _selectedThumbnailPath;
  String? _selectedImagePath;
  String? _selectedVideoPath;
  final List<String> _selectedCategories = [];
  bool _is18Plus = false;
  bool _isPrivate = false;
  String? _selectedQuality;
  String? _selectedTier;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    // Validação adicional
    if (widget.contentType == ContentType.video && _selectedVideoPath == null) {
      _showErrorSnackBar('Vídeo é obrigatório para conteúdo de vídeo');
      return;
    }

    if (_isPrivate && (_selectedTier == null || _selectedTier!.isEmpty)) {
      _showErrorSnackBar('Selecione um tier para conteúdo privado');
      return;
    }

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
    };

    widget.onSubmit(data);
  }

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
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campo título (Reddit-style)
          TextFormField(
            controller: _titleController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Título do post',
              hintStyle: TextStyle(color: AppColors.textGrey),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.cardBg,
              contentPadding: const EdgeInsets.all(16),
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
          const SizedBox(height: 16),

          // Campo descrição (Reddit-style text area)
          TextFormField(
            controller: _descriptionController,
            maxLines: 8,
            style: const TextStyle(fontSize: 16, height: 1.4),
            decoration: InputDecoration(
              hintText: 'Texto do post (opcional)',
              hintStyle: TextStyle(color: AppColors.textGrey),
              border: InputBorder.none,
              filled: true,
              fillColor: AppColors.cardBg,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value != null && value.length > 1000) {
                return 'Texto deve ter no máximo 1000 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Seção de mídia (Reddit-style)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adicionar mídia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                // Imagem para posts
                if (widget.contentType == ContentType.post)
                  FilePickerWidget(
                    label: 'Imagem',
                    hint: 'Escolher arquivo',
                    selectedFilePath: _selectedImagePath,
                    onFileSelected: (path) => setState(() => _selectedImagePath = path),
                    isVideo: false,
                    isRequired: false,
                  ),

                // Thumbnail e vídeo para vídeos
                if (widget.contentType == ContentType.video) ...[
                  FilePickerWidget(
                    label: 'Thumbnail',
                    hint: 'Escolher imagem',
                    selectedFilePath: _selectedThumbnailPath,
                    onFileSelected: (path) => setState(() => _selectedThumbnailPath = path),
                    isVideo: false,
                    isRequired: false,
                  ),
                  const SizedBox(height: 12),
                  FilePickerWidget(
                    label: 'Vídeo',
                    hint: 'Escolher vídeo',
                    selectedFilePath: _selectedVideoPath,
                    onFileSelected: (path) => setState(() => _selectedVideoPath = path),
                    isVideo: true,
                    isRequired: true,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Seção de configurações (Reddit + Patreon style)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurações do post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                // Categorias (como subreddits)
                Text(
                  'Comunidades',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FilterManager.availableFilters.map((filter) {
                    return FilterChip(
                      label: Text('r/$filter'),
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
                      backgroundColor: AppColors.background,
                      selectedColor: AppColors.btnSecondary.withOpacity(0.2),
                      checkmarkColor: AppColors.btnSecondary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Switches para configurações
                SwitchListTile(
                  title: Text('Conteúdo +18', style: TextStyle(color: AppColors.textDark)),
                  subtitle: Text('Marcar se contém conteúdo adulto', style: TextStyle(color: AppColors.textGrey)),
                  value: _is18Plus,
                  onChanged: (value) => setState(() => _is18Plus = value),
                  activeColor: AppColors.btnSecondary,
                ),

                SwitchListTile(
                  title: Text('Post exclusivo', style: TextStyle(color: AppColors.textDark)),
                  subtitle: Text('Apenas para assinantes pagantes', style: TextStyle(color: AppColors.textGrey)),
                  value: _isPrivate,
                  onChanged: (value) => setState(() => _isPrivate = value),
                  activeColor: AppColors.btnSecondary,
                ),

                // Seletor de tier (Patreon-style)
                if (_isPrivate) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Tier necessário',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTier,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    items: mockSupportTiers.map((tier) {
                      return DropdownMenuItem(
                        value: tier.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(int.parse('0xFF${tier.color.substring(1)}')),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${tier.name} - R\$ ${tier.price.toStringAsFixed(0)}/mês'),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedTier = value),
                    validator: (value) {
                      if (_isPrivate && (value == null || value.isEmpty)) {
                        return 'Selecione um tier';
                      }
                      return null;
                    },
                  ),
                ],

                // Qualidade para vídeos
                if (widget.contentType == ContentType.video) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Qualidade do vídeo',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedQuality,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Baixa (480p)')),
                      DropdownMenuItem(value: 'medium', child: Text('Média (720p)')),
                      DropdownMenuItem(value: 'high', child: Text('Alta (1080p)')),
                    ],
                    onChanged: (value) => setState(() => _selectedQuality = value),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botão de publicar (Reddit-style)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnSecondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Publicar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
