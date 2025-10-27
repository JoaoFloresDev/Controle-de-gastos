import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/firebase/saveExpensOnCloud.dart';

class TransactionsRepository {
  final LoginViewModel loginViewModel;

  TransactionsRepository({required this.loginViewModel});

  Future<List<CardModel>> retrieveCards() async {
    print("CHEGOU AQUI, USERID: ${loginViewModel.user!.displayName}");
    if (loginViewModel.isLogin) {
      return SaveExpensOnCloud().fetchCards(loginViewModel.user!.uid);
    } else {
      return CardService.retrieveCards();
    }
  }

  // MARK: - Add, Delete, and Update Cards
  Future<void> addCard(CardModel cardModel) async {
    if (loginViewModel.isLogin) {
      return SaveExpensOnCloud().addNewDate(loginViewModel.user!.uid, cardModel);
    } else {
      CardService().addCard(cardModel);
    }
  }

  Future<void> deleteCard(CardModel cardModel) async {
    if (loginViewModel.isLogin) {
      return SaveExpensOnCloud().addNewDate(loginViewModel.user!.uid, cardModel);
    } else {
      CardService().deleteCard(cardModel);
    }
  }

  Future<void> updateCard(CardModel oldCard, CardModel newCard) async {
    if (loginViewModel.isLogin) {
      SaveExpensOnCloud().deleteDate(loginViewModel.user!.uid, oldCard);
      SaveExpensOnCloud().addNewDate(loginViewModel.user!.uid, newCard);
    } else {
      CardService().updateCard(oldCard, newCard);
    }
  }

  // static Future<void> deleteAllCards() async {}
}
