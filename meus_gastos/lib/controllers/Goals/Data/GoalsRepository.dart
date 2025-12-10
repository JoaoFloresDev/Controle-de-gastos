import 'package:meus_gastos/controllers/Goals/Data/GoalsRepositoryLocal.dart';
import 'package:meus_gastos/controllers/Goals/Data/GoalsRepositoryRemote.dart';
import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:meus_gastos/controllers/Login/LoginViewModel.dart';

class GoalsRepository {
  final LoginViewModel loginVM;

  GoalsRepository({required this.loginVM});

  Future<void> addGoal(GoalModel goal) async {
    if (loginVM.isLogin) {
      GoalsRepositoryRemote(userId: loginVM.user!.uid).addGoal(goal);
    } else {
      GoalsRepositoryLocal().addGoal(goal);
    }
  }

  Future<void> deleteGoal(GoalModel goal) async {
    if (loginVM.isLogin) {
      GoalsRepositoryRemote(userId: loginVM.user!.uid).deleteGoal(goal.categoryId);
    } else {
      GoalsRepositoryLocal().deleteGoal(goal.categoryId);
    }
  }


  Future<List<GoalModel>> fetchGoals() async {
    if (loginVM.isLogin) {
      return GoalsRepositoryRemote(userId: loginVM.user!.uid).fetchGoals();
    } else {
      return GoalsRepositoryLocal().fetchGoals(); 
    }
  }
}
