import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/exportDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class Selectcategorys extends StatefulWidget {
  final List<CategoryModel> categorieList;
  final Function(List<int>) onSelectionChanged;
  final bool? changeWeek;
  const Selectcategorys(
      {required this.categorieList,
      required this.onSelectionChanged,
      this.changeWeek,
      Key? key})
      : super(key: key);

  @override
  SelectcategoryState createState() => SelectcategoryState();
}

class SelectcategoryState extends State<Selectcategorys> {
  Set<int> selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // In begin, all of categorys will be selects
    selectedIndices =
        Set<int>.from(Iterable<int>.generate(widget.categorieList.length));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categorieList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedIndices.contains(index)) {
                      selectedIndices.remove(index);
                    } else {
                      selectedIndices.add(index);
                    }
                  });
                  // Notify callback about change in selection of categories
                  widget.onSelectionChanged(selectedIndices.toList());
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: selectedIndices.contains(index)
                            ? AppColors.card.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.categorieList[index].icon,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Translateservice.getTranslatedCategoryUsingModel(
                          context, widget.categorieList[index]),
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.label,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.categorieList.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedIndices = Set<int>.from(
                        Iterable<int>.generate(widget.categorieList.length));
                  });
                  widget.onSelectionChanged(selectedIndices.toList());
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(80, 20),
                  backgroundColor: Colors.transparent,
                ),
                child: Text(AppLocalizations.of(context)!.selectAll,
                    style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedIndices = {};
                  });
                  widget.onSelectionChanged([]);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: const Size(80, 20),
                  backgroundColor: Colors.transparent,
                ),
                child: Text(AppLocalizations.of(context)!.clear,
                    style: const TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
      ],
    );
  }
}
