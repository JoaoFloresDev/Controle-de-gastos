import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class CategoryListItem extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onDeleted;

  const CategoryListItem({
    super.key,
    required this.category,
    required this.index,
    required this.onDeleted,
  });

  Future<void> _showDeleteDialog(BuildContext context) async {
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Excluir categoria"),
        content: const Text(
          "Tem certeza que deseja excluir esta categoria?",
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      HapticFeedback.mediumImpact();
      onDeleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(category.id),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            // ÁREA DE DRAG EXPANDIDA - Engloba ícone de 3 linhas + ícone da categoria
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                margin: const EdgeInsets.only(right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícone de 3 linhas (drag handle)
                    Icon(
                      CupertinoIcons.line_horizontal_3,
                      color: Colors.white.withOpacity(0.4),
                      size: 30,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Ícone da categoria (agora também faz parte da área de drag)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        category.icon,
                        color: category.color,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 14),
            
            // Nome da categoria
            Expanded(
              child: Text(
                TranslateService.getTranslatedCategoryUsingModel(
                  context,
                  category,
                ),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Botão deletar
            CupertinoButton(
              padding: const EdgeInsets.all(8),
              minSize: 0,
              onPressed: () => _showDeleteDialog(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  CupertinoIcons.trash,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}