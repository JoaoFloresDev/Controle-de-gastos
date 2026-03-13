import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/controllers/RecurrentExpense/fixedExpensesModel.dart';
import 'package:meus_gastos/services/firebase/FireBaseServiceSingleton.dart';

class FixedExpensesRepositoryRemote {
  final String userId;

  FixedExpensesRepositoryRemote({required this.userId});

  Future<List<FixedExpense>> fetch() async {
    try {
      QuerySnapshot snapshot = await FirebaseService()
          .firestore
          .collection(userId)
          .doc('fixedCards')
          .collection('cardList')
          .get();

      return snapshot.docs
          .map((doc) =>
              FixedExpense.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // fetch failed, return empty list
      return [];
    }
  }

  Future<void> add(FixedExpense card) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('fixedCards')
          .collection("cardList")
          .doc(card.id)
          .set(card.toJson());
    } catch (e) {
      // add failed silently
    }
  }

  Future<void> update(FixedExpense card) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('fixedCards')
          .collection("cardList")
          .doc(card.id)
          .update(card.toJson());
    } catch (e) {
      // update failed silently
    }
  }

  Future<void> delete(String cardId) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('fixedCards')
          .collection("cardList")
          .doc(cardId)
          .delete();
    } catch (e) {
      // deletion failed silently
    }
  }
}
