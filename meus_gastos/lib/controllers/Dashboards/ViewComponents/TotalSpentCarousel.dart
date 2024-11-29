import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/DashbordService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class TotalSpentCarouselWithTitles extends StatelessWidget {
  final List<Map<String, dynamic>> groupedPhrases = [
    {
      "sections": [
        {
          "title": "Média Diária",
          "phrases": [
            [
              "Geral: R\$ 123123",
            ],
            [
              "Custo fixo: R\$ 123123 (30%)",
              "Custo variável: R\$ 123123 (40%)"
            ],
            [
              "Dias úteis: R\$ 80 (20%)",
              "Finais de semana: R\$ 120 (80%)",
            ],
          ],
        },
        {
          "title": "Dias de maior custo variável",
          "phrases": [
            [
              "1. Sexta: R\$ 300 (10%)",
              "2. Sabado: R\$ 300 (10%)",
            ],
          ],
        },
        {
          "title": "Projeção para o mês",
          "phrases": [
            [
              "Geral: R\$ 1231",
            ],
            ["Custo fixo: R\$ 23434 (30%)", "Custo variável: R\$ 1323 (40%)"],
          ],
        },
      ],
    },
    {
      "sections": [
        {
          "title": "Meu mês até agora",
          "phrases": [
            ["Geral: R\$ 123123"],
            [
              "Gastos fixos: R\$ 123123 (70%)",
              "Gastos variáveis: R\$ 123123 (30%)"
            ],
            ["Custo médio por compra: R\$ 200", "Transações diárias: 3"],
            ["Dia mais caro do mês: 15/11 - R\$ 300"]
          ],
        },
        {
          "title": "Distribuição",
          "phrases": [
            [
              "1ª dezena: R\$ 100 (20%)",
              "2ª dezena: R\$ 100 (25%)",
              "3ª dezena: R\$ 1000 (30%)"
            ],
          ],
        },
      ],
    },
    {
      "sections": [
        {
          "title": "Mês atual / Mês anterior",
          "phrases": [
            ["Gasto geral: 1000 / 1000 (+10%)"],
            [
              "Gastos fixos: 1000 / 1000 (+10%)",
              "Gastos variáveis: 1000 / 1000 (+10%)",
            ],
            [
              "Gasto no fim de semana: 1000 / 1000 (+10%)",
              "Gasto no dia de semana: 1000 / 1000 (+10%)"
            ]
          ],
        },
        {
          "title": "Categorias",
          "phrases": [
            [
              "Maior aumento: Mercado (+10%)",
              "Maior queda: Agua (-20%)",
              "Mais usada: Luz (+20%)"
            ]
          ],
        },
      ],
    }
  ];

  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = const TextStyle(
      color: AppColors.label,
      fontSize: 16,
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
                  ..._buildGroupedRows(
                      phrases, tableHeaderStyle, tableCellStyle),
                  const SizedBox(height: 10), // Espaço entre seções
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
  ) {
    List<Widget> rows = [];
    for (int groupIndex = 0; groupIndex < phrases.length; groupIndex++) {
      final group = phrases[groupIndex];

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
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      children: _styleValue(value, tableCellStyle),
                    ),
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

  List<TextSpan> _styleValue(String value, TextStyle defaultStyle) {
    final RegExp regex =
        RegExp(r'\(([^)]+)\)'); // Captura valores entre parênteses
    final matches = regex.allMatches(value);

    if (matches.isEmpty) {
      return [TextSpan(text: value, style: defaultStyle)];
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    for (final match in matches) {
      final startIndex = match.start;
      final endIndex = match.end;

      if (currentIndex < startIndex) {
        spans.add(TextSpan(
          text: value.substring(currentIndex, startIndex),
          style: defaultStyle,
        ));
      }

      final capturedValue = match.group(1) ?? '';
      final styledValue = _getStyledValue(capturedValue);

      spans.add(TextSpan(
        text: styledValue,
        style: _getParenthesesStyle(capturedValue),
      ));

      currentIndex = endIndex;
    }

    if (currentIndex < value.length) {
      spans.add(TextSpan(
        text: value.substring(currentIndex),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  TextStyle _getParenthesesStyle(String value) {
    if (value.startsWith('+')) {
      return TextStyle(
          color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600);
    } else if (value.startsWith('-')) {
      return TextStyle(
          color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600);
    } else {
      return TextStyle(
          color: Color(0xFFB0BEC5), fontSize: 14, fontWeight: FontWeight.w400);
    }
  }

  String _getStyledValue(String value) {
    return value; // Apenas retorna o valor sem os parênteses
  }
}
