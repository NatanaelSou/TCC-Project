// lib/presentation/widgets/top_bar_widget.dart
//
// Package Imports
import 'package:flutter/material.dart';
//
// Resources Imports
import '../../core/constants/constants.dart';
import '../../providers/user_state.dart';

/// Widget para a barra superior com busca e avatar
class TopBarWidget extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final VoidCallback onCreateContent;
  final VoidCallback onProfileTap;
  final UserState userState;

  const TopBarWidget({
    super.key,
    required this.onSearch,
    required this.onCreateContent,
    required this.onProfileTap,
    required this.userState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Barra de busca
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar criadores ou tópicos',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
                  ),
                  filled: true,
                  fillColor: AppColors.inputFill,
                  contentPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLarge),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    onSearch(value.trim());
                  }
                },
              ),
            ),
          ),
          // Botões à direita
          Row(
            children: [
              // Botão de criar conteúdo
              IconButton(
                icon: Icon(Icons.add, color: AppColors.btnSecondary),
                onPressed: onCreateContent,
                tooltip: 'Criar conteúdo',
              ),
              const SizedBox(width: 10),
              // Avatar do usuário
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.btnSecondary,
                  backgroundImage: userState.avatarUrl != null
                      ? NetworkImage(userState.avatarUrl!)
                      : null,
                  child: userState.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
