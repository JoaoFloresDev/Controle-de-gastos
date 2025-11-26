import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'AddCategoryHorizontalCircleList.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'colorGridSelector.dart';

class CategoryForm extends StatelessWidget {
  final TextEditingController nameController;
  final Color selectedColor;
  final int selectedIconIndex;
  final ValueChanged<int> onIconSelected;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onSubmit;

  const CategoryForm({
    super.key,
    required this.nameController,
    required this.selectedColor,
    required this.selectedIconIndex,
    required this.onIconSelected,
    required this.onColorChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seletor de ícones com cor selecionada
        AddCategoryHorizontalCircleList(
          selectedColor: selectedColor, // Passa a cor selecionada
          onItemSelected: (index) {
            onIconSelected(index);
            HapticFeedback.lightImpact();
          },
        ),
        
        const SizedBox(height: 12),
        
        // Grid de seleção de cores
        ColorGridSelector(
          selectedColor: selectedColor,
          onColorSelected: onColorChanged,
        ),
        
        const SizedBox(height: 12),        
        // Campo de nome
        _buildNameField(context),
        
        const SizedBox(height: 12),
        
        // Botão adicionar
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildNameField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoTextField(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        placeholder: "Digite o nome da categoria",
        placeholderStyle: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 16,
        ),
        controller: nameController,
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
        ],
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: CupertinoButton(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(12),
        padding: EdgeInsets.zero,
        onPressed: () {
          if (nameController.text.isNotEmpty) {
            onSubmit();
            HapticFeedback.mediumImpact();
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.add_circled, size: 18),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.addCategory,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}