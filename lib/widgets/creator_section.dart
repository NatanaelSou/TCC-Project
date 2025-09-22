// lib/widgets/creator_section.dart
//
// Widget que exibe uma seção de criadores com suporte a filtragem múltipla
// Permite filtrar criadores por múltiplas categorias simultaneamente
// Suporte a seleção de vários filtros ao mesmo tempo para uma experiência mais flexível
import 'package:flutter/material.dart';
import '../constants.dart';

class CreatorSection extends StatelessWidget {
  // Título da seção
  final String title;
  // Filtros ativos para filtrar criadores por múltiplas categorias
  final List<String>? activeFilters;

  const CreatorSection({required this.title, this.activeFilters, super.key});

  // Dados de exemplo dos criadores com suas categorias
  // Cada criador possui nome, categoria, descrição e cor para visualização
  // Esta lista serve como dados mockados para demonstração da funcionalidade
  List<Map<String, dynamic>> get _creatorsData => [
    // Criador 1: Especialista em cultura pop
    {
      'name': 'João Silva',
      'category': 'Cultura pop',
      'description': 'Especialista em filmes e séries',
      'imageColor': Colors.blue[200],
    },
    // Criador 2: Conteúdo de comédia
    {
      'name': 'Maria Santos',
      'category': 'Comédia',
      'description': 'Conteúdo humorístico diário',
      'imageColor': Colors.orange[200],
    },
    // Criador 3: Jogos de RPG
    {
      'name': 'Pedro Costa',
      'category': 'Jogos de RPG',
      'description': 'Dicas e gameplays de RPG',
      'imageColor': Colors.green[200],
    },
    // Criador 4: Crimes reais
    {
      'name': 'Ana Oliveira',
      'category': 'Crimes reais',
      'description': 'Análise de casos famosos',
      'imageColor': Colors.red[200],
    },
    // Criador 5: Tutoriais de arte
    {
      'name': 'Carlos Mendes',
      'category': 'Tutoriais de arte',
      'description': 'Aulas de desenho digital',
      'imageColor': Colors.purple[200],
    },
    // Criador 6: Artesanato
    {
      'name': 'Beatriz Lima',
      'category': 'Artesanato',
      'description': 'DIY e trabalhos manuais',
      'imageColor': Colors.pink[200],
    },
    // Criador 7: Ilustração
    {
      'name': 'Rafael Dias',
      'category': 'Ilustração',
      'description': 'Arte digital e tradicional',
      'imageColor': Colors.teal[200],
    },
    // Criador 8: Música
    {
      'name': 'Fernanda Rocha',
      'category': 'Música',
      'description': 'Reviews e análises musicais',
      'imageColor': Colors.indigo[200],
    },
  ];

  // Filtra os criadores baseado nos filtros ativos (múltiplos filtros)
  // Implementa lógica OR - criador é mostrado se pertence a qualquer filtro selecionado
  List<Map<String, dynamic>> get _filteredCreators {
    // Caso especial: se não há filtros ativos, retorna todos os criadores
    if (activeFilters == null || activeFilters!.isEmpty) {
      return _creatorsData;
    }

    // Caso especial: se "Tudo" está selecionado, retorna todos os criadores
    // Isso permite que o usuário veja todo o conteúdo quando necessário
    if (activeFilters!.contains('Tudo')) {
      return _creatorsData;
    }

    // Lógica principal de filtragem múltipla:
    // - Usa where() para filtrar a lista de criadores
    // - Verifica se a categoria do criador está na lista de filtros ativos
    // - Retorna apenas criadores que correspondem a PELO MENOS UM dos filtros
    return _creatorsData.where((creator) {
      return activeFilters!.contains(creator['category']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Obtém a lista de criadores filtrados baseado nos filtros ativos
    final filteredCreators = _filteredCreators;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da seção com título e controles de navegação
        Row(
          children: [
            // Título da seção (ex: "Principais criadores", "Em alta esta semana")
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            // Espaço flexível para empurrar os botões para a direita
            Spacer(),
            // Botão de navegação para esquerda (funcionalidade futura)
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {},
              color: AppColors.iconDark,
            ),
            // Botão de navegação para direita (funcionalidade futura)
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {},
              color: AppColors.iconDark,
            ),
          ],
        ),
        SizedBox(height: 10),
        // Lista horizontal rolável de criadores filtrados
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            // Mapeia cada criador filtrado para um card visual
            children: filteredCreators.map((creator) => Container(
              width: 160,
              margin: EdgeInsets.only(right: 15),
              // Estilização do card do criador
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Área da imagem do criador com cor representativa
                  Container(
                    height: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      color: creator['imageColor'] as Color? ?? AppColors.cardImagePlaceholder,
                    ),
                  ),
                  // Informações do criador (nome e descrição)
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do criador em negrito
                        Text(
                          creator['name'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        // Descrição do criador em texto menor
                        Text(
                          creator['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }
}
