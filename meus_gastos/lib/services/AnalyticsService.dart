import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:meus_gastos/services/RatingGate.dart';

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

  // MARK: - Activation
  static const _coreActionKey = 'analytics.didCoreAction';

  /// The moment the app delivered its value. `first` marks the very first time on this
  /// install, which is what predicts retention.
  Future<void> coreAction(String kind, [Map<String, Object>? extra]) async {
    var first = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      first = !(prefs.getBool(_coreActionKey) ?? false);
      if (first) await prefs.setBool(_coreActionKey, true);
    } catch (_) {}
    await logEvent('core_action', {
      'kind': kind,
      'first': first.toString(),
      ...?extra,
    });
    // O momento de ativação também é o gatilho do rating gate — o serviço
    // decide sozinho se essa é a hora certa de perguntar.
    RatingGate.instance.recordPositiveEvent(trigger: kind);
  }

  /// Feature adoption, comparable across every app in the lab.
  Future<void> featureUsed(String name, {required String source}) =>
      logEvent('feature_used', {'name': name, 'source': source});

  // MARK: - Rating gate
  Future<void> ratingGateShown(String trigger) =>
      logEvent('rating_gate_shown', {'trigger': trigger});

  Future<void> ratingGateYes(String trigger) =>
      logEvent('rating_gate_yes', {'trigger': trigger});

  Future<void> ratingGateNo(String trigger) =>
      logEvent('rating_gate_no', {'trigger': trigger});

  Future<void> ratingGateDismissed(String trigger) =>
      logEvent('rating_gate_dismissed', {'trigger': trigger});

  Future<void> ratingGateFeedback(String trigger, String text) =>
      logEvent('rating_gate_feedback', {
        'trigger': trigger,
        'text': text.length > 90 ? text.substring(0, 90) : text,
      });

  // MARK: - Transactions
  Future<void> transactionAdded({required String category, required bool isRecurrent}) async {
    await logEvent('transaction_add', {
      'category': category,
      'is_recurrent': isRecurrent.toString(),
    });
    await coreAction('transaction_logged', {'is_recurrent': isRecurrent.toString()});
  }

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
  Future<void> paywallViewed(String source) async {
    await logEvent('paywall_shown', {'source': source});
    await logEvent('paywall_view', {'source': source});   // legacy, one release
  }

  Future<void> purchaseStarted(String productId) async {
    await logEvent('purchase_started', {'product_id': productId});
    await logEvent('purchase_start', {'product_id': productId});   // legacy, one release
  }

  Future<void> purchaseCompleted(String productId) =>
      logEvent('purchase_success', {'product_id': productId});

  Future<void> purchaseRestored() => logEvent('purchase_restored');

  Future<void> purchaseFailed(String productId) =>
      logEvent('purchase_fail', {'product_id': productId});

  // MARK: - Onboarding
  Future<void> onboardingStarted() => logEvent('onboarding_start');

  Future<void> onboardingStepViewed(int step) async {
    await logEvent('onboarding_step_viewed', {'step': step});
    await logEvent('onboarding_step', {'step': step});   // legacy, one release
  }

  Future<void> onboardingCompleted() async {
    await logEvent('onboarding_completed');
    await logEvent('onboarding_complete');   // legacy, one release
  }

  Future<void> onboardingSkipped(int atStep) =>
      logEvent('onboarding_skip', {'step': atStep});
}
