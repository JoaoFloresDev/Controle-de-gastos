import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/controllers/CategoryCreater/data/ICategoryRepository.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/firebase/FirebaseServiceSingleton.dart';

class CategoryRepositoryRemote implements ICategoryRepository {
  final String userId;

  CategoryRepositoryRemote({required this.userId});

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await deleteCategory(category.id);
    await addCategory(category);
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    if (userId == null) return;

    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('Categories')
          .collection('categoryList')
          .doc(category.id)
          .set(category.toJson());
      print("Categoria adicionada com sucesso: ${category.id}");
    } catch (e) {
      print("Erro ao adicionar categoria: $e");
    }
  }

  // try {
  //   List<CategoryModel> oldCategories = await getAllCategories();
  //   for (CategoryModel cat in oldCategories) {
  //     await deleteCategory(cat.id);
  //   }
  //   printAllCategories();
  //   for (CategoryModel cat in categories) {
  //     await addCategory(cat);
  //   }
  //   printAllCategories();
  // } catch (e) {
  //   print("Erro ao apagar");
  // }
  @override
  Future<void> saveOrderedCategories(List<CategoryModel> categories) async {
    try {
      final collection = FirebaseService()
          .firestore
          .collection(userId)
          .doc('Categories')
          .collection('categoryList');

      for (int i = 0; i < categories.length; i++) {

        final newPosition = i;

        print("Salvando posição: id=${categories[i].id}, pos=$newPosition");

        await collection
            .doc(categories[i].id)
            .update({"frequency": newPosition});
      }

      print("Ordem salva com sucesso!");
    } catch (e) {
      print("Erro ao salvar ordem: $e");
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('Categories')
          .collection('categoryList')
          .doc(id)
          .delete();

      print("Categoria com ID ${id} deletada com sucesso.");
    } catch (e) {
      print("Erro ao deletar categoria: $e");
    }
  }

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseService()
          .firestore
          .collection(userId)
          .doc('Categories')
          .collection('categoryList')
          .orderBy("frequency")
          .get();

      return snapshot.docs
          .map((doc) =>
              CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erro ao buscar categorias: $e");
      return [];
    }
  }

  Future<void> printAllCategories() async {
    List<CategoryModel> categories = await getAllCategories();
    categories = categories.where((cat) => cat.available).toList();
    for (var category in categories) {
      print(
          'ID: ${category.id}, Name: ${category.name}, Color: ${category.color}, Icon: ${category.icon}, Frequency: ${category.frequency}');
    }
  }
}
