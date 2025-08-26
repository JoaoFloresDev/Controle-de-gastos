import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class SelectCategories extends StatefulWidget {
  final List<CategoryModel> categoryList;
  final ValueChanged<List<int>> onSelectionChanged;
  final bool? changeWeek;

  const SelectCategories({
    required this.categoryList,
    required this.onSelectionChanged,
    this.changeWeek,
    super.key,
  });

  @override
  _SelectCategoriesState createState() => _SelectCategoriesState();
}

class _SelectCategoriesState extends State<SelectCategories> {
  Set<int> selectedIndices = {};

  @override
  void initState() {
    super.initState();
    selectedIndices =
        Set<int>.from(Iterable<int>.generate(widget.categoryList.length));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCategoryIcons(),
        if (widget.categoryList.isNotEmpty) _buildActionButtons(),
      ],
    );
  }

  Widget _buildCategoryIcons() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categoryList.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndices.contains(index);
          return GestureDetector(
            onTap: () => _toggleSelection(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIconContainer(isSelected, index),
                const SizedBox(height: 4),
                _buildCategoryLabel(index),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconContainer(bool isSelected, int index) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color:
            isSelected ? AppColors.buttonSelected : AppColors.buttonDeselected,
        shape: BoxShape.circle,
      ),
      child: Icon(widget.categoryList[index].icon,
          color: widget.categoryList[index].color),
    );
  }

  Widget _buildCategoryLabel(int index) {
    return Text(
      TranslateService.getTranslatedCategoryUsingModel(
          context, widget.categoryList[index]),
      style: const TextStyle(
        fontSize: 9,
        color: AppColors.label,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSelectAllButton(),
        const SizedBox(width: 10),
        _buildClearButton(),
      ],
    );
  }

  ElevatedButton _buildSelectAllButton() {
    return ElevatedButton(
      onPressed: _selectAll,
      style: _buttonStyle(),
      child: Text(
        AppLocalizations.of(context)!.selectAll,
        style: _buttonTextStyle(),
      ),
    );
  }

  ElevatedButton _buildClearButton() {
    return ElevatedButton(
      onPressed: _clearSelection,
      style: _buttonStyle(),
      child: Text(
        AppLocalizations.of(context)!.clear,
        style: _buttonTextStyle(),
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minimumSize: const Size(80, 20),
      backgroundColor: Colors.transparent,
    );
  }

  TextStyle _buttonTextStyle() {
    return const TextStyle(
      fontSize: 12,
      color: AppColors.button,
      fontWeight: FontWeight.bold,
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      if (selectedIndices.contains(index)) {
        selectedIndices.remove(index);
      } else {
        selectedIndices.add(index);
      }
    });
    widget.onSelectionChanged(selectedIndices.toList());
  }

  void _selectAll() {
    setState(() {
      selectedIndices =
          Set<int>.from(Iterable<int>.generate(widget.categoryList.length));
    });
    widget.onSelectionChanged(selectedIndices.toList());
  }

  void _clearSelection() {
    setState(() {
      selectedIndices.clear();
    });
    widget.onSelectionChanged([]);
  }
}
