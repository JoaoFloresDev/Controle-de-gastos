import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class TotalSpentCarousel extends StatefulWidget {
  final double totalGasto;
  final List<String> motivationalPhrases;

  const TotalSpentCarousel({
    super.key,
    required this.totalGasto,
    required this.motivationalPhrases,
  });

  @override
  _TotalSpentCarouselState createState() => _TotalSpentCarouselState();
}

class _TotalSpentCarouselState extends State<TotalSpentCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final TextStyle commonTextStyle = const TextStyle(
      color: AppColors.label,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );

    final List<Widget> carouselItems = [
      Text(
        "Total Spent: \$${widget.totalGasto.toStringAsFixed(2)}",
        style: commonTextStyle,
        textAlign: TextAlign.center,
      ),
      ...widget.motivationalPhrases.map(
        (phrase) => Text(
          phrase,
          style: commonTextStyle,
          textAlign: TextAlign.center,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            child: PageView.builder(
              itemCount: carouselItems.length,
              controller: PageController(viewportFraction: 0.9),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  child: Center(child: carouselItems[index]),
                );
              },
            ),
          ),
          // const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              carouselItems.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 14 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.button
                      : AppColors.labelPlaceholder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
