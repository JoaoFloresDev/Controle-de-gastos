import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/firebase/saveOnClound.dart';

class SaveExpensOnCloud extends Saveonclound {

  Future<void> addDatesOfOfflineState() async {
    List<CardModel> cards = await CardService.retrieveCards();
    for (var card in cards) {
      await firestore.collection(userId!).doc(card.id).set(card.toJson());
      // await firestore.collection(userId).doc(card.id)
    }
  }

  Future<void> addNewDate(CardModel card) async {
    print("**************************************************** ${userId!}");
    await firestore
        .collection(userId!)
        .doc('NormalCards')
        .collection("cardList")
        .doc(card.id)
        .set(card.toJson());
  }

  Future<void> deleteDate(CardModel card) async {
    try {
      await firestore
        .collection(userId!)
        .doc('NormalCards')
        .collection("cardList")
        .doc(card.id)
        .delete();

        print("Document with ID ${card.id} deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }
  
  Future<List<CardModel>> fetchCards() async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection(userId!)
          .doc('NormalCards')
          .collection('cardList')
          .get();

      return snapshot.docs
          .map((doc) => CardModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar cartões: $e');
      return [];
    }
  }

  // MARK: fixed cards
  
  Future<void> addDatesOfOfflineStateFixedCards() async {
    List<FixedExpense> cards = await Fixedexpensesservice.retrieveCards();
    for (var card in cards) {
      await firestore.collection(userId!).doc(card.id).set(card.toJson());
      // await firestore.collection(userId).doc(card.id)
    }
  }

  Future<void> addNewDateFixedCards(FixedExpense card) async {
      if (userId == null) {
      print("Erro: userId é null!");
      return;
    }
    print("**************************************************** ${userId!}");
    try {
      await firestore
        .collection(userId!)
        .doc('fixedCards')
        .collection("cardList")
        .doc(card.id)
        .set(card.toJson());
      print("Gasto salvo com sucesso!");
    } catch (e) {
      print("Erro ${e}");
    }
    

  }

  Future<void> deleteDateFixedCards(FixedExpense card) async {
    try {
      await firestore
        .collection(userId!)
        .doc('fixedCards')
        .collection("cardList")
        .doc(card.id)
        .delete();

        print("Document with ID ${card.id} deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }
  
  Future<List<FixedExpense>> fetchCardsFixedCards() async {
    try {
      QuerySnapshot snapshot = await firestore
          .collection(userId!)
          .doc('fixedCards')
          .collection('cardList')
          .get();
    
      return snapshot.docs
          .map((doc) => FixedExpense.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar cartões: $e');
      return [];
    }
  }

  // categories

  Future<void> addNewCategory(CategoryModel category) async {
  try {
    await firestore
        .collection(userId!)
        .doc('Categories')
        .collection('categoryList')
        .doc(category.id)
        .set(category.toJson());

    print("Categoria adicionada com sucesso: ${category.id}");
  } catch (e) {
    print("Erro ao adicionar categoria: $e");
  }
}

Future<void> deleteCategory(CategoryModel category) async {
  try {
    await firestore
        .collection(userId!)
        .doc('Categories')
        .collection('categoryList')
        .doc(category.id)
        .delete();

    print("Categoria com ID ${category.id} deletada com sucesso.");
  } catch (e) {
    print("Erro ao deletar categoria: $e");
  }
}

Future<List<CategoryModel>> fetchCategories() async {
  try {
    QuerySnapshot snapshot = await firestore
        .collection(userId!)
        .doc('Categories')
        .collection('categoryList')
        .get();

    return snapshot.docs
        .map((doc) => CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print("Erro ao buscar categorias: $e");
    return [];
  }
}

}

// colocar date antes do id no nome do arquivo para quando sincronizar pegar apenas os arquivos feitos depois da ultima sincronização
// 