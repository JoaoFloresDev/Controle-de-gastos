import 'package:meus_gastos/controllers/CategoryCreater/data/ICategoryRepository.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

class CategoryRepositorySelector implements ICategoryRepository {
  ICategoryRepository remoteRepository;
  final ICategoryRepository localRepository;
  bool isLoggedIn;

  CategoryRepositorySelector(
      {required this.remoteRepository,
      required this.localRepository,
      required this.isLoggedIn});
  ICategoryRepository get _activeRepo =>
      isLoggedIn ? remoteRepository : localRepository;

  @override
  Future<List<CategoryModel>> getAllCategories() =>
      _activeRepo.getAllCategories();

  @override
  Future<void> addCategory(CategoryModel CategoryModel) =>
      _activeRepo.addCategory(CategoryModel);

  @override
  Future<void> saveOrderedCategories(List<CategoryModel> categories) => _activeRepo.saveOrderedCategories(categories);

  @override
  Future<void> deleteCategory(String categoryId) =>
      _activeRepo.deleteCategory(categoryId);

  @override
  Future<void> updateCategory(CategoryModel category) =>
      _activeRepo.updateCategory(category);

  void updateSource(bool newIsLoggedIn) {
    isLoggedIn = newIsLoggedIn;
  }
}
