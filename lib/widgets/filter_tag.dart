// lib/widgets/filter_tag.dart
//
// Widget que representa uma tag de filtro clicável
// Permite filtrar conteúdo por categoria
import 'package:flutter/material.dart';
import '../constants.dart';

class FilterTag extends StatelessWidget {
  // Propriedades do widget
  final String label; // Texto exibido na tag
  final bool active; // Se a tag está ativa/selecionada
  final VoidCallback? onTap; // Função chamada quando a tag é clicada

  // Construtor com parâmetros obrigatórios e opcionais
  const FilterTag({
    required this.label,
    this.active = false,
    this.onTap,
    super.key,
  });

  // Constrói a interface visual do widget
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Define a ação de toque
      child: Container(
        margin: EdgeInsets.only(right: 10), // Espaçamento à direita
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Padding interno
        decoration: BoxDecoration(
          // Cor baseada no estado ativo/inativo
          color: active ? AppColors.sidebarItemActive : Colors.grey[300],
          borderRadius: BorderRadius.circular(25), // Bordas arredondadas
        ),
        child: Text(
          label,
          style: TextStyle(
            // Cor do texto baseada no estado ativo/inativo
            color: active ? AppColors.textLight : AppColors.textDark,
            fontWeight: FontWeight.bold, // Texto em negrito
          ),
        ),
      ),
    );
  }
}
