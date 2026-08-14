import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Central funnel for every analytics call in the app.
/// Never throws: analytics must not break a user flow.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics get _analytics => FirebaseAnalytics.instance;

  Future<void> logScreen(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      debugPrint('AnalyticsService.logScreen($screenName) failed: $e');
    }
  }

  Future<void> logEvent(String name, [Map<String, Object>? params]) async {
    try {
      await _analytics.logEvent(name: name, parameters: params);
    } catch (e) {
      debugPrint('AnalyticsService.logEvent($name) failed: $e');
    }
  }

  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (e) {
      debugPrint('AnalyticsService.setUserProperty($name) failed: $e');
    }
  }

  // MARK: - Transactions
  Future<void> transactionAdded({required String category, required bool isRecurrent}) =>
      logEvent('transaction_add', {
        'category': category,
        'is_recurrent': isRecurrent.toString(),
      });

  Future<void> transactionEdited() => logEvent('transaction_edit');

  Future<void> transactionDeleted() => logEvent('transaction_delete');

  // MARK: - Categories
  Future<void> categoryCreated(String name) =>
      logEvent('category_create', {'category': name});

  Future<void> categoryDeleted() => logEvent('category_delete');

  Future<void> categoryEdited() => logEvent('category_edit');

  // MARK: - Goals
  Future<void> goalSet({required String category}) =>
      logEvent('goal_set', {'category': category});

  // MARK: - Export
  Future<void> exportShared(String format) =>
      logEvent('export_share', {'format': format});

  // MARK: - Auth
  Future<void> loginSuccess(String method) async {
    await _analytics.logLogin(loginMethod: method).catchError((_) {});
  }

  Future<void> logoutDone() => logEvent('logout');

  // MARK: - Purchase
  Future<void> paywallViewed(String source) =>
      logEvent('paywall_view', {'source': source});

  Future<void> purchaseStarted(String productId) =>
      logEvent('purchase_start', {'product_id': productId});

  Future<void> purchaseCompleted(String productId) =>
      logEvent('purchase_success', {'product_id': productId});

  Future<void> purchaseRestored() => logEvent('purchase_restore');

  Future<void> purchaseFailed(String productId) =>
      logEvent('purchase_fail', {'product_id': productId});

  // MARK: - Onboarding
  Future<void> onboardingStarted() => logEvent('onboarding_start');

  Future<void> onboardingStepViewed(int step) =>
      logEvent('onboarding_step', {'step': step});

  Future<void> onboardingCompleted() => logEvent('onboarding_complete');

  Future<void> onboardingSkipped(int atStep) =>
      logEvent('onboarding_skip', {'step': atStep});
}
