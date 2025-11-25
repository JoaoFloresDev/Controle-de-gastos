import 'package:meus_gastos/controllers/Dashboards/ViewComponents/monthInsights/MonthInsightsViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'dart:io';

import 'package:provider/provider.dart';

class MonthInsightsScreen extends StatefulWidget {
  late final Future<double> dailyAverageSpent;

  MonthInsightsScreen({
    Key? key,
  }) : super(key: key);

  @override
  MonthInsightsScreenState createState() => MonthInsightsScreenState();
}

class MonthInsightsScreenState extends State<MonthInsightsScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: AppColors.background1);
  }

  @override
  Widget build(BuildContext context) {
    MonthInsightsViewModel monthInsightsVM =
        context.watch<MonthInsightsViewModel>();

    if (monthInsightsVM.isLoading) return _buildLoadingIndicator();

    final groupedPhrases =
        monthInsightsVM.buildGroupedPhrases(context, monthInsightsVM.currentDate);
    return Stack(
      children: [
        PageView.builder(
          itemCount: groupedPhrases.length,
          controller: _pageController,
          itemBuilder: (context, index) {
            final group = groupedPhrases[index];
            final sections = group['sections'] as List<Map<String, dynamic>>;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 16, bottom: 0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 32, 32, 32),
                    AppColors.card2
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).toInt()),
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
                          fontSize: 18,
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
                                final value = parts.sublist(1).join(':').trim();
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            color: AppColors.label,
                                            fontSize: 16,
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
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            if (i < phrases.length - 1)
                              const Divider(
                                color: Colors.grey,
                                thickness: 0.5,
                                height: 10,
                              ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
        if (Platform.isMacOS) ...[
          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.button),
              onPressed: () {
                final prevPage = ((_pageController.page?.round() ?? 0) - 1);
                if (prevPage >= 0) {
                  _pageController.animateToPage(
                    prevPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: IconButton(
              icon:
                  const Icon(Icons.arrow_forward_ios, color: AppColors.button),
              onPressed: () {
                final nextPage = ((_pageController.page?.round() ?? 0) + 1);
                if (nextPage < groupedPhrases.length) {
                  _pageController.animateToPage(
                    nextPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ],
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
}
