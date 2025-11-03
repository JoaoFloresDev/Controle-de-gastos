import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/repositories/Transactions/ITransactionsRepository.dart';

class TransactionsRepositorySelector implements ITransactionsRepository {
  ITransactionsRepository remoteRepository;
  final ITransactionsRepository localRepository;
  bool isLoggedIn;

  TransactionsRepositorySelector(
      {required this.remoteRepository,
      required this.localRepository,
      required this.isLoggedIn});
  ITransactionsRepository get _activeRepo =>
      isLoggedIn ? remoteRepository : localRepository;

  @override
  Future<List<CardModel>> retrieve() => _activeRepo.retrieve();

  @override
  Future<void> addCard(CardModel cardModel) => _activeRepo.addCard(cardModel);

  @override
  Future<void> deleteCard(CardModel card) => _activeRepo.deleteCard(card);

  @override
  Future<void> updateCard(CardModel oldCard, CardModel newCard) =>
      _activeRepo.updateCard(oldCard, newCard);

  void updateSource(bool newIsLoggedIn, String newUserId) {
    isLoggedIn = newIsLoggedIn;
  }

}
