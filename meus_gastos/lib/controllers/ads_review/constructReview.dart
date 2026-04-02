import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  Future<void> checkAndRequestReview(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int sessionCount = prefs.getInt('session_count') ?? 0;

    sessionCount += 1;

    if (sessionCount == 4) {
      _showCustomReviewDialog(context);
    }
    await prefs.setInt('session_count', sessionCount);
  }

  void _showCustomReviewDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(localizations.reviewAppTitle),
          content: Text(localizations.reviewAppDescription),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(localizations.notNow),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _redirectToAppStore();
              },
              child: Text(localizations.reviewButton),
            ),
          ],
        );
      },
    );
  }

  void _redirectToAppStore() {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing(
      appStoreId: '6502218501',
    );
  }

}
