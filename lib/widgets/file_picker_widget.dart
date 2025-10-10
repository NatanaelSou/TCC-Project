import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';

/// Widget para seleção de arquivos (imagens ou vídeos)
class FilePickerWidget extends StatefulWidget {
  final String label;
  final String hint;
  final String? selectedFilePath;
  final Function(String?) onFileSelected;
  final bool isVideo;
  final bool isRequired;

  const FilePickerWidget({
    super.key,
    required this.label,
    required this.hint,
    this.selectedFilePath,
    required this.onFileSelected,
    this.isVideo = false,
    this.isRequired = false,
  });

  @override
  State<FilePickerWidget> createState() => _FilePickerWidgetState();
}

class _FilePickerWidgetState extends State<FilePickerWidget> {
  final ImagePicker _imagePicker = ImagePicker();

  /// Seleciona arquivo do dispositivo
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result;

      if (widget.isVideo) {
        // Para vídeos, usar file picker com filtro de vídeo
        result = await FilePicker.platform.pickFiles(
          type: FileType.video,
          allowMultiple: false,
        );
      } else {
        // Para imagens, mostrar opções
        await _showImageSourceDialog();
        return;
      }

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        widget.onFileSelected(filePath);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar arquivo: ${e.toString()}');
    }
  }

  /// Mostra diálogo para escolher fonte da imagem
  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecionar imagem'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Galeria'),
              onTap: () {
                Navigator.of(context).pop();
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.file_open),
              title: Text('Arquivo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImageFile();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Seleciona imagem da galeria
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        widget.onFileSelected(image.path);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar imagem: ${e.toString()}');
    }
  }

  /// Seleciona arquivo de imagem
  Future<void> _pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        widget.onFileSelected(filePath);
      }
    } catch (e) {
      _showErrorSnackBar('Erro ao selecionar arquivo: ${e.toString()}');
    }
  }

  /// Remove arquivo selecionado
  void _removeFile() {
    widget.onFileSelected(null);
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

  /// Obtém nome do arquivo do caminho
  String _getFileName(String path) {
    return path.split(RegExp(r'[/\\]')).last;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          widget.label + (widget.isRequired ? ' *' : ''),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        SizedBox(height: AppDimensions.spacingSmall),

        // Campo de arquivo
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          ),
          child: Column(
            children: [
              // Área de seleção
              InkWell(
                onTap: _pickFile,
                child: Container(
                  padding: EdgeInsets.all(AppDimensions.spacingMedium),
                  child: Row(
                    children: [
                      Icon(
                        widget.isVideo ? Icons.video_file : Icons.image,
                        color: AppColors.btnSecondary,
                      ),
                      SizedBox(width: AppDimensions.spacingMedium),
                      Expanded(
                        child: Text(
                          widget.selectedFilePath != null
                              ? _getFileName(widget.selectedFilePath!)
                              : widget.hint,
                          style: TextStyle(
                            color: widget.selectedFilePath != null
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.attach_file,
                        color: AppColors.btnSecondary,
                      ),
                    ],
                  ),
                ),
              ),

              // Arquivo selecionado com preview e botão remover
              if (widget.selectedFilePath != null)
                Container(
                  padding: EdgeInsets.all(AppDimensions.spacingSmall),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppDimensions.borderRadiusMedium),
                      bottomRight: Radius.circular(AppDimensions.borderRadiusMedium),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Preview da imagem
                      if (!widget.isVideo && !kIsWeb)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                              image: FileImage(File(widget.selectedFilePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else if (!widget.isVideo && kIsWeb)
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.image,
                            color: Colors.grey[600],
                          ),
                        )
                      else
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.play_circle_fill,
                            color: AppColors.btnSecondary,
                          ),
                        ),

                      SizedBox(width: AppDimensions.spacingSmall),

                      // Nome do arquivo
                      Expanded(
                        child: Text(
                          _getFileName(widget.selectedFilePath!),
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Botão remover
                      IconButton(
                        icon: Icon(Icons.close, size: 16),
                        onPressed: _removeFile,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
