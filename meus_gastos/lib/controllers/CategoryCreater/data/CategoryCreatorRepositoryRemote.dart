import 'package:meus_gastos/models/CategoryModel.dart';

class CategoryCreatorRepository {
  Future<void> addCategory(CategoryModel category) async {}

  Future<void> deleteCategory(String id) async {}

  Future<List<CategoryModel>> getAllCategories() async {
    return [];
  }

  Future<List<CategoryModel>> getAllCategoriesAvaliable() async {
    return [];
  }

  Future<void> printAllCategories() async {
    final categories = await getAllCategories();
    for (var category in categories) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    }
  }

  Future<void> incrementCategoryFrequency(String categoryId) async {}

  Future<CategoryModel?> getCategoryWithHighestFrequency() async {
    List<CategoryModel> categories = await getAllCategories();

    if (categories.isEmpty) return null;

    CategoryModel highestFrequencyCategory = categories.reduce((a, b) {
      final aFreq = a.frequency ?? 0;
      final bFreq = b.frequency ?? 0;
      return aFreq > bFreq ? a : b;
    });

    return highestFrequencyCategory;
  }
}
