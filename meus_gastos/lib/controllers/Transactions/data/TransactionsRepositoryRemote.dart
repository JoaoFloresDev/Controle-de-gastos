import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/ITransactionsRepository.dart';
import 'package:meus_gastos/services/firebase/FirebaseServiceSingleton.dart';

class TransactionsRepositoryRemote implements ITransactionsRepository {
  final String userId;

  TransactionsRepositoryRemote({required this.userId});

  @override
  Future<void> addCard(CardModel card) async {
    // Sem try/catch — a VM precisa saber que falhou para fazer rollback do
    // optimistic update. Antes engolia o erro e o card "fantasma" sumia
    // silenciosamente no próximo reload.
    card.updatedAt = DateTime.now();
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
    // Soft delete: marca tombstone via set() em vez de apagar o doc.
    // Sem isso, em multi-device a deleção sumia: device A apaga, device B
    // ainda tem no remote (porque o merge antigo só fazia putIfAbsent), e
    // no próximo sync o card ressuscitava em A.
    card.deleted = true;
    card.updatedAt = DateTime.now();
    await FirebaseService()
        .firestore
        .collection(userId)
        .doc('NormalCards')
        .collection("cardList")
        .doc(card.id)
        .set(card.toJson());
  }

  @override
  Future<List<CardModel>> retrieve() async {
    // Retorna TUDO incluindo tombstones — UI filtra na VM. Se filtrasse aqui,
    // o SyncService leria sem tombstones e não propagaria deleções entre
    // devices.
    try {
      QuerySnapshot snapshot = await FirebaseService()
          .firestore
          .collection(userId)
          .doc('NormalCards')
          .collection('cardList')
          .get();

      return snapshot.docs
          .map((doc) => CardModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    } catch (e) {
      // fetch failed, return empty list
      return [];
    }
  }

  @override
  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    // set() idempotente: se o app crashar no meio, o doc ainda existe.
    // O id é o mesmo (CardModel.id não muda em update), então só sobrescreve.
    await addCard(newCard);
  }
}