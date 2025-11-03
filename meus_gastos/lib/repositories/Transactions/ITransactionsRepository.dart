import 'package:meus_gastos/models/CardModel.dart';

abstract class ITransactionsRepository {
  Future<List<CardModel>> retrieve();
  Future<void> addCard(CardModel cardModel);
  Future<void> deleteCard(CardModel card);
  Future<void> updateCard(CardModel oldCard, CardModel newCard);
}
