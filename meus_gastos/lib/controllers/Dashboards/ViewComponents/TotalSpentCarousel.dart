import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class TotalSpentCarouselWithTitles extends StatelessWidget {
  final double totalGasto;
  final List<Map<String, dynamic>> groupedPhrases;

  const TotalSpentCarouselWithTitles({
    super.key,
    required this.totalGasto,
    required this.groupedPhrases,
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = const TextStyle(
      color: AppColors.label,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    final TextStyle tableHeaderStyle = const TextStyle(
      color: AppColors.labelPlaceholder,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    final TextStyle tableCellStyle = const TextStyle(
      color: AppColors.label,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );

    final TextStyle parenthesesStyle = const TextStyle(
      color: AppColors.button,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );

    return PageView.builder(
      itemCount: groupedPhrases.length,
      controller: PageController(viewportFraction: 0.9),
      itemBuilder: (context, index) {
        final group = groupedPhrases[index];
        final sections = group['sections'] as List<Map<String, dynamic>>;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections.map<Widget>((section) {
              final title = section['title'] as String;
              final phrases = section['phrases'] as List<List<String>>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleStyle),
                  const SizedBox(height: 2),
                  ..._buildGroupedRows(phrases, tableHeaderStyle,
                      tableCellStyle, parenthesesStyle,
                      isLastSection: section == sections.last),
                  const SizedBox(height: 8), // Espaço entre seções
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _buildGroupedRows(
    List<List<String>> phrases,
    TextStyle tableHeaderStyle,
    TextStyle tableCellStyle,
    TextStyle parenthesesStyle, {
    required bool isLastSection,
  }) {
    List<Widget> rows = [];
    for (int groupIndex = 0; groupIndex < phrases.length; groupIndex++) {
      final group = phrases[groupIndex];

      // Itera por cada frase dentro do grupo
      for (int phraseIndex = 0; phraseIndex < group.length; phraseIndex++) {
        final phrase = group[phraseIndex];
        final parts = phrase.split(':');
        final label = parts[0];
        final value = parts.sublist(1).join(':').trim();

        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    label,
                    style: tableHeaderStyle,
                    textAlign: TextAlign.left, // Alinha o texto à esquerda
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    value,
                    textAlign: TextAlign.right, // Alinha o valor à direita
                    style: tableCellStyle,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Adiciona divisor entre os grupos, exceto após o último grupo
      if (groupIndex < phrases.length - 1) {
        rows.add(const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ));
      }
    }
    return rows;
  }
}
