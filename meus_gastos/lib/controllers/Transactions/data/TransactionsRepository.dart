import 'package:meus_gastos/controllers/Login/Authentication.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/firebase/saveExpensOnCloud.dart';

class TransactionsRepository {
  final Authentication _authService;

  TransactionsRepository(this._authService);

  Future<List<CardModel>> retrieveCards() async {
    if (_authService.userId == null) {
      return CardService.retrieveCards();
    } else {
      return SaveExpensOnCloud().fetchCards();
    }
  }

  // MARK: - Add, Delete, and Update Cards
  Future<void> addCard(CardModel cardModel) async {
    if (_authService.userId == null) {
      CardService().addCard(cardModel);
    } else {
      return SaveExpensOnCloud().addNewDate(cardModel);
    }
  }

  Future<void> deleteCard(CardModel cardModel) async {
    if (_authService.userId == null) {
      CardService().deleteCard(cardModel);
    } else {
      return SaveExpensOnCloud().addNewDate(cardModel);
    }
  }

  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    if (_authService.userId == null) {
      CardService().updateCard(oldCard, newCard);
    } else {
      SaveExpensOnCloud().deleteDate(oldCard);
      SaveExpensOnCloud().addNewDate(newCard);
    }
  }

  // static Future<void> deleteAllCards() async {}
}
