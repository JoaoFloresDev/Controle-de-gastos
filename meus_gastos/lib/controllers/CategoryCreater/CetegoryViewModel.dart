import 'package:flutter/material.dart';
import 'package:meus_gastos/ViewsModelsGerais/SyncViewModel.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/ICategoryRepository.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/AnalyticsService.dart';

class CategoryViewModel extends ChangeNotifier {
  final ICategoryRepository repo;
  final SyncViewModel syncVM;
  List<CategoryModel> categories = [];
  List<CategoryModel> avaliebleCetegories = [];

  bool isLoading = false;

  CategoryViewModel({required this.repo, required this.syncVM}) {
    syncVM.addListener(_onSync);
  }

  void _onSync() {
    if (syncVM.hasSynced) {
      load();
    }
  }

  @override
  void dispose() {
    syncVM.removeListener(_onSync);
    super.dispose();
  }

  Future<void> load() async {
    // Mostra spinner apenas quando não há cache em memória — em refreshes
    // (login/sync) mantém a lista anterior visível e atualiza silenciosamente
    // quando chegar, evitando o flash do CircularProgressIndicator na tela
    // de adição.
    final bool hasCache = categories.isNotEmpty;
    if (!hasCache) {
      isLoading = true;
      notifyListeners();
    }

    categories = await repo.getAllCategories();
    final withoutAddCategory =
        categories.where((cat) => cat.id != 'AddCategory').toList();

    final addCategoryList =
        categories.where((cat) => cat.id == 'AddCategory').toList();

    categories = addCategoryList.isNotEmpty
        ? [...withoutAddCategory, addCategoryList.first]
        : withoutAddCategory;
    avaliebleCetegories = getAllCategoriesAvaliable();

    isLoading = false;
    notifyListeners();
  }

  List<CategoryModel> getAllCategoriesAvaliable() {
    List<CategoryModel> cat = categories.where((cat) => cat.available).toList();
    return cat;
  }

  Future<void> add(CategoryModel c) async {
    AnalyticsService().categoryCreated(c.name);
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
    avaliebleCetegories = List<CategoryModel>.from(getAllCategoriesAvaliable());

    // categories.sort((a, b) => a.frequency.compareTo(b.frequency));
    // avaliebleCetegories = getAllCategoriesAvaliable();

    // for (var category in categories) {
    //   print(
    //       'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    // }
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

    for (int i = 0; i < reorderedList.length; i++) {
      final match = categories.where((cat) => cat.id == reorderedList[i].id);
      if (match.isNotEmpty) {
        match.first.frequency = reorderedList[i].frequency;
      }
    }

    // categories = reorderedList;
    avaliebleCetegories = List.from(reorderedList); // Cria nova lista

    notifyListeners(); // UI atualiza AGORA
  }

// Método ASSÍNCRONO - salva no Firebase em background
  Future<void> saveOrderedCategoriesToFirebase(List<CategoryModel> cats) async {
    try {
      await repo.saveOrderedCategories(cats);
    } catch (_) {
      // silently ignore — UI does not require feedback for background save
    }
  }

  Future<void> update(CategoryModel c) async {
    AnalyticsService().categoryEdited();
    await repo.updateCategory(c);
    int index = categories.indexWhere((x) => x.id == c.id);
    if (index != -1) categories[index] = c;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    AnalyticsService().categoryDeleted();
    await repo.deleteCategory(id);
    final match = categories.where((c) => c.id == id);
    if (match.isNotEmpty) match.first.available = false;
    avaliebleCetegories = getAllCategoriesAvaliable();
    notifyListeners();
  }
}
