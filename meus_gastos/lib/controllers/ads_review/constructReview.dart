import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static Future<void> checkAndRequestReview(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int sessionCount = prefs.getInt('session_count') ?? 0;
    sessionCount += 1;
    await prefs.setInt('session_count', sessionCount);

    if (sessionCount == 16) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
    } else if (sessionCount == 32) {
      _showCustomReviewDialog(context);
    }
  }

  static void _showCustomReviewDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!; // Obtém localizações do contexto

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.add),
          content: Text(localizations.reviewAppDescription),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o popup
              },
              child: Text(localizations.notNow),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o popup
                _redirectToAppStore();
              },
              child: Text(localizations.reviewButton),
            ),
          ],
        );
      },
    );
  }

  static void _redirectToAppStore() {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing(
      appStoreId: '6502218501',
    );
  }
}
