import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/firebase/FirebaseService.dart';

class SaveExpensOnCloud {
  Future<void> addDatesOfOfflineState() async {
    if (FirebaseService().userId == null) return;
    List<CardModel> cards = await CardService.retrieveCards();
    for (var card in cards) {
      await FirebaseService()
          .firestore
          .collection(FirebaseService().userId!)
          .doc(card.id)
          .set(card.toJson());
      // await firestore.collection(userId).doc(card.id)
    }
  }

  Future<void> addNewDate(String? userId, CardModel card) async {
    if (userId == null) return;

    await FirebaseService()
        .firestore
        .collection(FirebaseService().userId!)
        .doc('NormalCards')
        .collection("cardList")
        .doc(card.id)
        .set(card.toJson());
  }

  Future<void> deleteDate(String? userId, CardModel card) async {
    try {
      if (userId == null) return;

      await FirebaseService()
          .firestore
          .collection(FirebaseService().userId!)
          .doc('NormalCards')
          .collection("cardList")
          .doc(card.id)
          .delete();

      print("Document with ID ${card.id} deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  Future<List<CardModel>> fetchCards(String? userId) async {
    try {
      if (userId == null) return [];
      print("Chegou aqui e o usuário é: $userId");
      QuerySnapshot snapshot = await FirebaseService()
          .firestore
          .collection(FirebaseService().userId!)
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
}