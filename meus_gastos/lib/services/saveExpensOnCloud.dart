import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';

class SaveExpensOnCloud {
  String? userId;
  SaveExpensOnCloud() : userId = FirebaseAuth.instance.currentUser?.uid {
    // TODO: implement SaveExpensOnCloud
    throw UnimplementedError();
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addDatesOfOfflineState() async {
    List<CardModel> cards = await CardService.retrieveCards();
    for (var card in cards) {
      await _firestore.collection(userId!).doc(card.id).set(card.toJson());
      // await _firestore.collection(userId).doc(card.id)
    }
  }

  Future<void> addNewDate(CardModel card) async {
    await _firestore.collection(userId!).doc(card.id).set(card.toJson());
  }
}

// colocar date antes do id no nome do arquivo para quando sincronizar pegar apenas os arquivos feitos depois da ultima sincronização
// 