// lib/widgets/sidebar_item.dart
//
// package
import 'package:flutter/material.dart';
import '../constants.dart'; // para cores

// Item da Sidebar
class SidebarItem extends StatelessWidget {
  // Propriedades
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback? onTap;
  final bool expanded;

  // Construtor
  const SidebarItem({super.key, 
    required this.icon,
    required this.label,
    this.active = false,
    this.onTap,
    this.expanded = true, // por padrão a sidebar está expandida
  });

  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      // estilo
      decoration: BoxDecoration(
        color: active ? AppColors.sidebarItemActive : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      // Conteúdo
      child: expanded
          ? ListTile(
              leading: Icon(
                icon,
                color: active ? AppColors.textLight : AppColors.textDark,
              ),
              title: Text(
                label,
                style: TextStyle(
                  color: active ? AppColors.textLight : AppColors.textDark,
                ),
              ),
              onTap: onTap,
              horizontalTitleGap: 8,
              minLeadingWidth: 32,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            )
          : Container(
              decoration: BoxDecoration(
                color: active ? AppColors.sidebarItemActive : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: active ? AppColors.textLight : AppColors.textDark,
                    size: 20,
                  ),
                ),
              ),
            ),
    );
  }
}

// Prompt para se tornar criador
class SidebarPrompt extends StatelessWidget {
  // Callback quando o botão for pressionado
  final VoidCallback? onPressed;
  final bool expanded; // se a sidebar estiver expandida ou retraída
  final VoidCallback? onClose; // callback para fechar o prompt

  // Construtor
  const SidebarPrompt({super.key, this.onPressed, this.expanded = true, this.onClose});

  // Construção do Widget
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      // estilo
      decoration: BoxDecoration(
        color: AppColors.sidebarPromptBg,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: AppColors.sidebarPromptShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      // Conteúdo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expanded)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seja um criador',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: onClose ?? () {}, // usa o callback onClose ou função vazia
                ),
              ],
            ),
          if (expanded) SizedBox(height: 8),
          Text(
            expanded
                ? 'Crie uma assinatura para seus fãs e receba para criar da forma que quiser.'
                : '',
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(height: expanded ? 12 : 0), // espaço maior se expandido
          // Botão
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.btnSecondary,
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onPressed,
              child: Text(
                expanded ? 'Comece agora mesmo' : 'Criar',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
