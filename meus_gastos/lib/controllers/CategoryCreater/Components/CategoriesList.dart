import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CetegoryViewModel.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:provider/provider.dart';
import 'categoryListItem.dart';

class CategoriesList extends StatelessWidget {
  final List<CategoryModel> categories;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String categoryId) onCategoryDeleted;

  const CategoriesList(
      {super.key,
      required this.categories,
      required this.onReorder,
      required this.onCategoryDeleted});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty || categories.length <= 1) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          _buildReorderableList(context),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.square_stack_3d_up,
                size: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(height: 8),
              Text(
                "Nenhuma categoria criada",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.list_bullet,
            size: 16,
            color: Colors.white.withOpacity(0.6),
          ),
          const SizedBox(width: 6),
          Text(
            "Minhas Categorias",
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Icon(
            CupertinoIcons.arrow_up_arrow_down,
            size: 14,
            color: Colors.white.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderableList(BuildContext context) {
      List<CategoryModel> categories = context.watch<CategoryViewModel>().avaliebleCetegories;

      return ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 14, left: 10, right: 10),
        buildDefaultDragHandles: false,
        itemCount: categories.length - 1,
        onReorder: (oldIndex, newIndex) => onReorder(oldIndex, newIndex),
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            child: child,
          );
        },
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryListItem(
            key: ValueKey(category.id),
            category: category,
            index: index,
            onDeleted: () => onCategoryDeleted(categories[index].id),
          );
        },
      );
  }
}
