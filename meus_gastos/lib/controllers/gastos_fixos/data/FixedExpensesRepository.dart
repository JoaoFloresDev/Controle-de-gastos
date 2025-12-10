import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/data/FixedExpensesRepositoryLocal.dart';
import 'package:meus_gastos/controllers/gastos_fixos/data/FixedExpensesRepositoryRemote.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';

class FixedExpensesRepository {
  final LoginViewModel loginVM;
  late FixedExpensesRepositoryRemote remoteRepo;
  late FixedExpensesRepositoryLocal localRepo;
  FixedExpensesRepository(this.loginVM) {
    if (loginVM.isLogin) {
      remoteRepo = FixedExpensesRepositoryRemote(userId: loginVM.user!.uid);
    } else {
      localRepo = FixedExpensesRepositoryLocal();
    }
  }

  Future<List<FixedExpense>> fetch() async {
    List<FixedExpense> fixedExpenses = [];
    if (loginVM.isLogin) {
      fixedExpenses = await remoteRepo.fetch();
    } else {
      fixedExpenses = await localRepo.fetch();
    }
    return fixedExpenses;
  }

  Future<void> add(FixedExpense card) async {
    if (loginVM.isLogin) {
      await remoteRepo.add(card);
    } else {
      await localRepo.add(card);
    }
  }

  Future<void> update(FixedExpense card) async {
    if (loginVM.isLogin) {
      await remoteRepo.update(card);
    } else {
      await localRepo.update(card);
    }
  }

  Future<void> delete(String cardId) async {
    if (loginVM.isLogin) {
      await remoteRepo.delete(cardId);
    } else {
      await localRepo.delete(cardId);
    }
  }
}
