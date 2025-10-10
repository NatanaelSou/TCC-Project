import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile_models.dart';
import '../services/content_service.dart';
import '../constants.dart';
import '../user_state.dart';
import '../widgets/post_creation_form.dart';

/// Página para criação de novo conteúdo estilo Reddit
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
  final _contentService = ContentService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cardBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Criar ${widget.contentType.name}',
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => _showDraftDialog(),
            child: Text(
              'Rascunho',
              style: TextStyle(
                color: AppColors.btnSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header estilo Reddit
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.btnSecondary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Postando como',
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${Provider.of<UserState>(context).user?.name ?? 'Anônimo'}',
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Formulário
              PostCreationForm(
                contentType: widget.contentType,
                onSubmit: _handleFormSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleFormSubmit(Map<String, dynamic> data) async {
    // Obtém o creatorId e navigator antes de qualquer operação assíncrona
    final userState = Provider.of<UserState>(context, listen: false);
    final creatorId = userState.user?.id?.toString() ?? '1';
    final navigator = Navigator.of(context);

    setState(() => _isLoading = true);

    try {
      // Adiciona creatorId aos dados
      data['creatorId'] = creatorId;

      // Cria o conteúdo
      final content = await _contentService.createContent(creatorId, data);

      if (!mounted) return;

      if (content != null) {
        // Retorna o conteúdo criado para a página anterior
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showDraftDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Salvar rascunho?'),
        content: const Text('Seu post será salvo como rascunho para continuar editando depois.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implementar salvamento de rascunho
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rascunho salvo (não implementado)')),
              );
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
