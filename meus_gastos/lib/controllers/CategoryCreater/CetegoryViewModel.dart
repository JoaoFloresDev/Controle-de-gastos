import 'package:flutter/material.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/ICategoryRepository.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

class CategoryViewModel extends ChangeNotifier {
  final ICategoryRepository repo;

  List<CategoryModel> categories = [];
  List<CategoryModel> avaliebleCetegories = [];

  bool isLoading = false;

  CategoryViewModel({required this.repo});

  Future<void> load() async {
    isLoading = true;
    notifyListeners();

    categories = await repo.getAllCategories();
    final withoutAddCategory =
        categories.where((cat) => cat.id != 'AddCategory').toList();

    final addCategory =
        categories.where((cat) => cat.id == 'AddCategory').toList().first;

    categories = [...withoutAddCategory, addCategory];
    avaliebleCetegories = await getAllCategoriesAvaliable();

    isLoading = false;
    notifyListeners();
  }

  List<CategoryModel> getAllCategoriesAvaliable() {
    List<CategoryModel> cat = categories.where((cat) => cat.available).toList();
    return cat;
  }

  Future<void> add(CategoryModel c) async {
    await repo.addCategory(c);
    categories.add(c);
    notifyListeners();
  }

  Future<void> saveOrderedCategories(List<CategoryModel> cats) async {
    // isLoading = true;

    final updated = <CategoryModel>[];
    for (int i = 0; i < cats.length; i++) {
      final c = cats[i];
      updated.add(CategoryModel(
        id: c.id,
        name: c.name,
        color: c.color,
        icon: c.icon,
        frequency: i, // índice = ordem
      ));
    }

    categories = updated;
    avaliebleCetegories = List<CategoryModel>.from(updated);

    // categories.sort((a, b) => a.frequency.compareTo(b.frequency));
    // avaliebleCetegories = getAllCategoriesAvaliable();

    for (var category in categories) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    }
    notifyListeners();

    await repo.saveOrderedCategories(cats);

    // isLoading = false;
    notifyListeners();
  }

  void updateCategoriesOrder(List<CategoryModel> reorderedList) {
    // Atualiza frequencies
    for (int i = 0; i < reorderedList.length; i++) {
      reorderedList[i].frequency = i;
    }

    categories = reorderedList;
    avaliebleCetegories = List.from(reorderedList); // Cria nova lista

    notifyListeners(); // UI atualiza AGORA
  }

// Método ASSÍNCRONO - salva no Firebase em background
  Future<void> saveOrderedCategoriesToFirebase(List<CategoryModel> cats) async {
    try {
      await repo.saveOrderedCategories(cats);
      print("Ordem salva no Firebase com sucesso!");
    } catch (e) {
      print("Erro ao salvar no Firebase: $e");
      // Opcional: mostrar snackbar de erro
    }
  }

  Future<void> update(CategoryModel c) async {
    await repo.updateCategory(c);
    int index = categories.indexWhere((x) => x.id == c.id);
    if (index != -1) categories[index] = c;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await repo.deleteCategory(id);
    categories.where((c) => c.id == id).first.available = false;
    avaliebleCetegories = getAllCategoriesAvaliable();
    notifyListeners();
  }
}
