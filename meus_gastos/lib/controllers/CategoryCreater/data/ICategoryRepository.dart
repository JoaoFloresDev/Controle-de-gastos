import 'package:meus_gastos/models/CategoryModel.dart';

abstract class ICategoryRepository {
  Future<List<CategoryModel>> getAllCategories();
  Future<void> addCategory(CategoryModel cardModel);
  Future<void> saveOrderedCategories(List<CategoryModel> categories);
  Future<void> deleteCategory(String cardID);
  Future<void> updateCategory(CategoryModel card);
}
