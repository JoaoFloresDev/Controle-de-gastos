import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meus_gastos/controllers/Goals/GoalsModel.dart';
import 'package:meus_gastos/services/firebase/FirebaseServiceSingleton.dart';

class GoalsRepositoryRemote {
  final String userId;

  GoalsRepositoryRemote({required this.userId});

  Future<List<GoalModel>> fetchGoals() async {
    try {
      QuerySnapshot snapshot = await FirebaseService()
          .firestore
          .collection(userId)
          .doc('goals')
          .collection('goalsList')
          .get();

      return snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // save
  Future<void> addGoal(GoalModel goal) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('goals')
          .collection('goalsList')
          .doc(goal.categoryId)
          .set(goal.toJson());
    } catch (e) {
      print("Erro ao salvar meta: $e");
    }
  }

  // delete
  Future<void> deleteGoal(String goalId) async {
    try {
      await FirebaseService()
          .firestore
          .collection(userId)
          .doc('goals')
          .collection('goalsList')
          .doc(goalId)
          .delete();
    } catch (e) {
      print("erro: $e");
    }
  }
}
