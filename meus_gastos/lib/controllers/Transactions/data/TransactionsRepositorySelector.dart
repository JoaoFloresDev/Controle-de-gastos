import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/controllers/Transactions/data/ITransactionsRepository.dart';
import 'package:meus_gastos/services/AnalyticsService.dart';

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
  Future<void> addCard(CardModel cardModel) {
    AnalyticsService().transactionAdded(
      category: cardModel.category.name,
      isRecurrent: cardModel.idFixoControl.isNotEmpty,
    );
    return _activeRepo.addCard(cardModel);
  }

  @override
  Future<void> deleteCard(CardModel card) {
    AnalyticsService().transactionDeleted();
    return _activeRepo.deleteCard(card);
  }

  @override
  Future<void> updateCard(CardModel oldCard, CardModel newCard) {
    AnalyticsService().transactionEdited();
    return _activeRepo.updateCard(oldCard, newCard);
  }

  void updateSource(bool newIsLoggedIn, String newUserId) {
    isLoggedIn = newIsLoggedIn;
  }

}
