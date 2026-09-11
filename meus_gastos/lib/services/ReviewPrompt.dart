// ReviewPrompt.dart — GambitStudio review prompt, copied from the lab's Flutter
// template (_GambitStudio/templates/flutter/review_prompt.dart), logic unchanged.
//
// The app's only way to ask for a rating: the native in-app review prompt,
// requested directly at the app's aha-moment. There is no pre-prompt — no
// "do you like it?" sheet, no feedback form in front of the review. The lab
// shipped one and dropped it on 2026-09-11 (LEARNINGS #88); don't bring it back
// under another name. Mirrors GambitCoreKit's ReviewService.
//
// Dependencies (pubspec.yaml):
//   in_app_review
//   shared_preferences
//
// Wiring in this app:
//   1. main(): ReviewPrompt.instance.onEvent -> AnalyticsService().logEvent
//      (review_prompt_requested). appVersion stays null: the app has no
//      package_info_plus.
//   2. Aha-moment: TransactionsViewModel.addManualCard records
//      recordPositiveEvent(trigger: 'expense_saved') — an expense typed and
//      saved in a month the user is tracking, still within budget.
//   3. Settings "Rate" row: published app ->
//        InAppReview.instance.openStoreListing(appStoreId: '6502218501');

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewPrompt {
  ReviewPrompt._();
  static final ReviewPrompt instance = ReviewPrompt._();

  // -- Config ---------------------------------------------------------------

  /// Aha-moments before the first request — the user has to come back to the
  /// value, not just see it once.
  int minPositiveEvents = 3;

  /// Days between two automatic requests.
  int cooldownDays = 90;

  /// Automatic requests per 365 days. iOS draws the prompt at most 3 times a
  /// year; asking more only spends attempts.
  int maxRequestsPerYear = 3;

  /// Wait after the aha-moment so the success UI settles first.
  Duration delay = const Duration(seconds: 1);

  /// When set, at most one automatic request per app version.
  String? appVersion;

  /// Analytics hook: ('review_prompt_requested', {'trigger': ...}). Fires when
  /// the request reaches the platform — whether it was drawn is not observable.
  void Function(String name, Map<String, Object> params)? onEvent;

  // -- Storage --------------------------------------------------------------

  static const _kPositiveCount = 'review.positiveCount';
  static const _kRequests = 'review.requestsMs';
  static const _kLastVersion = 'review.lastRequestVersion';
  static const _kLegacyMigrated = 'review.legacyMigrated';

  // Keys the app's old pre-prompt service wrote (removed 2026-09-11). They are
  // the same as the lab template's defaults, so its history carries over as is.
  static const _kLegacyPositiveCount = 'gate.positiveCount';
  static const _kLegacyLastShown = 'gate.lastShownMs';
  static const _kLegacyNativePrompts = 'gate.nativePromptsMs';

  bool _pending = false;

  // -- Public API -----------------------------------------------------------

  /// Call right after the user gets the app's value. Returns true when a
  /// request was scheduled. Does not wait out the delay — safe to call from a
  /// save handler.
  Future<bool> recordPositiveEvent({String trigger = 'aha_moment'}) async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacy(prefs);
    final count = (prefs.getInt(_kPositiveCount) ?? 0) + 1;
    await prefs.setInt(_kPositiveCount, count);
    if (_pending || !isEligible(prefs, count, DateTime.now())) return false;
    _pending = true;
    unawaited(Future<void>.delayed(delay, () => _request(trigger)));
    return true;
  }

  /// Asks right now, skipping every rule above. Only for a request the user
  /// made — the Settings "Rate" row of an app that is not published yet.
  Future<void> promptNow() async {
    final review = InAppReview.instance;
    if (!await review.isAvailable()) return;
    await review.requestReview();
    onEvent?.call('review_prompt_requested', {'trigger': 'settings'});
  }

  // -- Eligibility ----------------------------------------------------------

  @visibleForTesting
  bool isEligible(SharedPreferences prefs, int positiveCount, DateTime now) {
    if (positiveCount < minPositiveEvents) return false;
    final requests = _requests(prefs);
    if (requests.isNotEmpty &&
        now.difference(requests.last) < Duration(days: cooldownDays)) {
      return false;
    }
    final yearAgo = now.subtract(const Duration(days: 365));
    if (requests.where((d) => d.isAfter(yearAgo)).length >=
        maxRequestsPerYear) {
      return false;
    }
    final version = appVersion;
    if (version != null && prefs.getString(_kLastVersion) == version) {
      return false;
    }
    return true;
  }

  // -- Request --------------------------------------------------------------

  Future<void> _request(String trigger) async {
    try {
      // The user left during the delay: keep the attempt for the next one.
      if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
        return;
      }
      final review = InAppReview.instance;
      if (!await review.isAvailable()) return;
      await review.requestReview();
      final prefs = await SharedPreferences.getInstance();
      await _recordRequest(prefs, DateTime.now());
      onEvent?.call('review_prompt_requested', {'trigger': trigger});
    } finally {
      _pending = false;
    }
  }

  Future<void> _recordRequest(SharedPreferences prefs, DateTime now) async {
    await _storeRequests(prefs, _requests(prefs)..add(now));
    final version = appVersion;
    if (version != null) await prefs.setString(_kLastVersion, version);
  }

  List<DateTime> _requests(SharedPreferences prefs) {
    return _parseMillis(prefs.getStringList(_kRequests))..sort();
  }

  Future<void> _storeRequests(
      SharedPreferences prefs, List<DateTime> dates) async {
    final kept =
        dates.length > 10 ? dates.sublist(dates.length - 10) : dates;
    await prefs.setStringList(
        _kRequests, kept.map((d) => '${d.millisecondsSinceEpoch}').toList());
  }

  static List<DateTime> _parseMillis(List<String>? raw) {
    return (raw ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .map(DateTime.fromMillisecondsSinceEpoch)
        .toList();
  }

  /// Carries over, once, the old pre-prompt's history: someone who saw that
  /// sheet last month was already interrupted — that counts toward the
  /// cooldown, or the first build without the sheet would ask them again.
  Future<void> _migrateLegacy(SharedPreferences prefs) async {
    if (prefs.getBool(_kLegacyMigrated) ?? false) return;
    await prefs.setBool(_kLegacyMigrated, true);

    final legacyCount = prefs.getInt(_kLegacyPositiveCount) ?? 0;
    if (legacyCount > (prefs.getInt(_kPositiveCount) ?? 0)) {
      await prefs.setInt(_kPositiveCount, legacyCount);
    }

    final lastShown = prefs.getInt(_kLegacyLastShown);
    final dates = <DateTime>[
      ..._requests(prefs),
      ..._parseMillis(prefs.getStringList(_kLegacyNativePrompts)),
      if (lastShown != null) DateTime.fromMillisecondsSinceEpoch(lastShown),
    ]..sort();
    // "Yes" on the old sheet wrote lastShown and a native-prompt time seconds
    // apart: one interruption, not two.
    final merged = <DateTime>[];
    for (final date in dates) {
      if (merged.isEmpty ||
          date.difference(merged.last) >= const Duration(hours: 1)) {
        merged.add(date);
      }
    }
    await _storeRequests(prefs, merged);
  }
}
