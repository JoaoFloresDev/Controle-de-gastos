import 'package:meus_gastos/controllers/Login/Authentication.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/firebase/saveExpensOnCloud.dart';

class TransactionsRepository {
  final Authentication authService;

  TransactionsRepository({required this.authService});

  Future<List<CardModel>> retrieveCards() async {
    print("CHEGOU AQUI, USERID: ${authService.userId}");
    if (authService.userId == null) {
      return CardService.retrieveCards();
    } else {
      return SaveExpensOnCloud().fetchCards();
    }
  }

  // MARK: - Add, Delete, and Update Cards
  Future<void> addCard(CardModel cardModel) async {
    if (authService.userId == null) {
      CardService().addCard(cardModel);
    } else {
      return SaveExpensOnCloud().addNewDate(cardModel);
    }
  }

  Future<void> deleteCard(CardModel cardModel) async {
    if (authService.userId == null) {
      CardService().deleteCard(cardModel);
    } else {
      return SaveExpensOnCloud().addNewDate(cardModel);
    }
  }

  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    if (authService.userId == null) {
      CardService().updateCard(oldCard, newCard);
    } else {
      SaveExpensOnCloud().deleteDate(oldCard);
      SaveExpensOnCloud().addNewDate(newCard);
    }
  }


  // static Future<void> deleteAllCards() async {}
}
