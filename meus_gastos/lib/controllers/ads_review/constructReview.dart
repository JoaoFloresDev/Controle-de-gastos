import 'dart:io';

import 'package:meus_gastos/services/ProManeger.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static Future<void> checkAndRequestReview(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int sessionCount = prefs.getInt('session_count') ?? 0;
    bool isPro = await ProManeger().checkUserProStatus();
    sessionCount += 1;
    await prefs.setInt('session_count', sessionCount);

    if (sessionCount == 4) {
      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
      }
    } else if (sessionCount == 8 ||
        ((sessionCount % 3 == 0 && !(sessionCount % 5 == 0)) &&
            sessionCount > 10)) {
      if (!isPro) {
        _showProModal(context);
      }
    } else if (sessionCount == 10 || sessionCount % 11 == 0) {
      _showCustomReviewDialog(context);
    }
  }

  static void _showCustomReviewDialog(BuildContext context) {
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

  static void _redirectToAppStore() {
    final InAppReview inAppReview = InAppReview.instance;
    inAppReview.openStoreListing(
      appStoreId: '6502218501',
    );
  }

  static void _showProModal(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        if (Platform.isIOS || Platform.isMacOS) {
          return ProModal(
            isLoading: false,
            onSubscriptionPurchased: () {},
          );
        } else {
          return ProModalAndroid(
            isLoading: true,
            onSubscriptionPurchased: () {},
          );
        }
      },
    );
  }
}
