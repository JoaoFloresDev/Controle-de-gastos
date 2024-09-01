import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constructreview {
  static Future<void> checkAndRequestReview() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int sessionCount = prefs.getInt('session_count') ?? 0;
    sessionCount += 1;
    await prefs.setInt('session_count', sessionCount);
    print("É a $sessionCount vez");
    // Solicite a avaliação após 5 sessões
    if (sessionCount >= 5) {
      final InAppReview inAppReview = InAppReview.instance;
      print("É a quinta vez");
      if (await inAppReview.isAvailable()) {
        // Exibe a solicitação de avaliação se disponível
        print("E entrou");
        inAppReview.requestReview();
        sessionCount = 0;
        prefs.setInt('session_count', sessionCount);
      }
    }
  }
}