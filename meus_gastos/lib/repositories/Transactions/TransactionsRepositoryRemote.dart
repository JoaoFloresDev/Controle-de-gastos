import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/repositories/Transactions/ITransactionsRepository.dart';
import 'package:meus_gastos/services/firebase/FirebaseServiceSingleton.dart';

class TransactionsRepositoryRemote implements ITransactionsRepository {
  final String userId;

  TransactionsRepositoryRemote({required this.userId});

  @override
  Future<void> addCard(CardModel card) async {
    
    if (userId == null) return;

    await FirebaseService()
        .firestore
        .collection(userId)
        .doc('NormalCards')
        .collection("cardList")
        .doc(card.id)
        .set(card.toJson());
  }
  
@override
  Future<void> deleteCard(CardModel card) async {
    try {
      if (userId == null) return;

      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('NormalCards')
          .collection("cardList")
          .doc(card.id)
          .delete();

      print("Document with ID ${card.id} deleted successfully.");
    } catch (e) {
      print("Error deleting document: $e");
    }
  }

  @override
  Future<List<CardModel>> retrieve() async {
    try {
      if (userId == null) return [];
      QuerySnapshot snapshot = await FirebaseService()
          .firestore
          .collection(userId)
          .doc('NormalCards')
          .collection('cardList')
          .get();

      return snapshot.docs
          .map((doc) => CardModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList()..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      print('Erro ao buscar cartões: $e');
      return [];
    }
  }

  @override
  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    await deleteCard(oldCard);
    await addCard(newCard);
  }
}