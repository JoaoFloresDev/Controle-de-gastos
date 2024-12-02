import 'package:meus_gastos/services/CardService.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class TotalSpentCarouselWithTitles extends StatelessWidget {
  final DateTime currentMonth;
  late final Future<double> dailyAverageSpent;

  Future<double> calculateTotalSpent() async {
    final List<double> monthlyExpenses =
        await CardService.getTotalExpensesByMonth(currentMonth);
    return monthlyExpenses.reduce((value, element) => value + element);
  }

  TotalSpentCarouselWithTitles({
    Key? key,
    required this.currentMonth,
  }) : super(key: key) {
    dailyAverageSpent = calculateDailyAverageSpent();
  }

  Future<double> calculateDailyAverageSpent() async {
    final totalSpent = await calculateTotalSpent();
    final int daysPassed = DateTime.now().day;
    return totalSpent / daysPassed;
  }

  Future<List<Map<String, dynamic>>> buildGroupedPhrases() async {
    return [
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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: buildGroupedPhrases(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.label),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: AppColors.label),
            ),
          );
        } else {
          final groupedPhrases = snapshot.data ?? [];
          return PageView.builder(
            itemCount: groupedPhrases.length,
            controller: PageController(viewportFraction: 0.9),
            itemBuilder: (context, index) {
              final group = groupedPhrases[index];
              final sections = group['sections'] as List<Map<String, dynamic>>;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 16, bottom: 16),
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
                        Text(
                          title,
                          style: const TextStyle(
                            color: AppColors.label,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (int i = 0; i < phrases.length; i++) ...[
                              Column(
                                children: phrases[i].map((phrase) {
                                  final parts = phrase.split(':');
                                  final label = parts[0].trim();
                                  final value =
                                      parts.sublist(1).join(':').trim();

                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            label,
                                            style: const TextStyle(
                                              color: AppColors.label,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: RichText(
                                              text: TextSpan(
                                                children: _styleValue(
                                                    value,
                                                    const TextStyle(
                                                      color: AppColors.label,
                                                      fontSize: 14,
                                                    )),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              // Adiciona divisor entre grupos de frases, exceto após o último
                              if (i < phrases.length - 1)
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 0.5,
                                  height: 0,
                                ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              );
            },
          );
        }
      },
    );
  }

  List<TextSpan> _styleValue(String value, TextStyle defaultStyle) {
    final RegExp regex =
        RegExp(r'\(([-+]?\d+)%\)'); // Captura números entre parênteses
    final match = regex.firstMatch(value);

    if (match != null) {
      final percentage = match.group(1);
      final styledValue =
          value.replaceAll(regex, '').trim(); // Remove o parêntese e conteúdo

      final color = percentage!.startsWith('+')
          ? Colors.red
          : percentage.startsWith('-')
              ? Colors.green
              : Colors.grey;

      return [
        TextSpan(
          text: styledValue,
          style: defaultStyle,
        ),
        TextSpan(
          text: ' $percentage%',
          style: TextStyle(
            color: color,
            fontSize: defaultStyle.fontSize! * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ];
    }

    return [TextSpan(text: value, style: defaultStyle)];
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

      if (groupIndex < phrases.length - 1) {
        rows.add(const Divider(
          color: Colors.grey,
          thickness: 0.5,
        ));
      }
    }
    return rows;
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
