import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/firebase/FirebaseService.dart';

class SaveCategoryOnClound {
  Future<void> addNewCategory(CategoryModel category) async {
    try {
      await FirebaseService().firestore
          .collection(FirebaseService().userId!)
          .doc('Categories')
          .collection('categoryList')
          .doc(category.id)
          .set(category.toJson());

      // User? user = FirebaseAuth.instance.currentUser;

    // if (user != null) {
    //   // Usuário logado: adiciona ao Firestore
    //   await FirebaseFirestore.instance
    //       .collection(user.uid)
    //       .doc('Categories')
    //       .collection('categoryList')
    //       .doc(category.id)
    //       .set(category.toJson());
    // } else {
    
      print("Categoria adicionada com sucesso: ${category.id}");
    } catch (e) {
      print("Erro ao adicionar categoria: $e");
    }
  }

  Future<void> deleteCategory(CategoryModel category) async {
    try {
      await FirebaseService().firestore
          .collection(FirebaseService().userId!)
          .doc('Categories')
          .collection('categoryList')
          .doc(category.id)
          .delete();

      // User? user = FirebaseAuth.instance.currentUser;

    // if (user != null) {
    //   // Usuário logado: atualiza a categoria no Firestore (marca como indisponível)
    //   final docRef = FirebaseFirestore.instance
    //       .collection(user.uid)
    //       .doc('Categories')
    //       .collection('categoryList')
    //       .doc(id);

    //   final docSnapshot = await docRef.get();

    //   if (docSnapshot.exists) {
    //     await docRef.update({'available': false});
    //   }
    // } else {

      print("Categoria com ID ${category.id} deletada com sucesso.");
    } catch (e) {
      print("Erro ao deletar categoria: $e");
    }
  }

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      QuerySnapshot snapshot = await FirebaseService().firestore
          .collection(FirebaseService().userId!)
          .doc('Categories')
          .collection('categoryList')
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

  // User? user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   // Usuário está logado - verificamos o Firestore
      //   final firestore = FirebaseFirestore.instance;
      //   final snapshot = await firestore
      //       .collection(user.uid)
      //       .doc('Categories')
      //       .collection('categoryList')
      //       .get();
      //   if (snapshot.docs.isEmpty) {
      //     // Primeiro acesso na nuvem
      //     for (var category in defaultCategories) {
      //       await SaveExpensOnCloud().addNewCategory(category);
      //     }
      //     return defaultCategories
      //       ..sort((a, b) => b.frequency.compareTo(a.frequency));
      //   } else {
      //     // Categorias já existem
      //     List<CategoryModel> cloudCategories = snapshot.docs
      //         .map((doc) =>
      //             CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
      //         .toList()
      //       ..sort((a, b) => b.frequency.compareTo(a.frequency));
      //     // cloudCategories =
      //     //     cloudCategories.where((cat) => cat.available).toList();

      //     return cloudCategories;
      //   }
      // } else {

}
