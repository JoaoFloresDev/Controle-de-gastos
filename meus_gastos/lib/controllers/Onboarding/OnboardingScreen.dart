import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/services/AnalyticsService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  static const hasSeenKey = 'hasSeenOnboarding';

  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final String heroAsset;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) description;

  const _OnboardingPage({
    required this.heroAsset,
    required this.title,
    required this.description,
  });
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  static final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      heroAsset: 'assets/onboarding/hero_track.png',
      title: (l) => l.onboardingTrackTitle,
      description: (l) => l.onboardingTrackDesc,
    ),
    _OnboardingPage(
      heroAsset: 'assets/onboarding/hero_charts.png',
      title: (l) => l.onboardingChartsTitle,
      description: (l) => l.onboardingChartsDesc,
    ),
    _OnboardingPage(
      heroAsset: 'assets/onboarding/hero_goals.png',
      title: (l) => l.onboardingGoalsTitle,
      description: (l) => l.onboardingGoalsDesc,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService().onboardingStarted();
    AnalyticsService().onboardingStepViewed(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _persistAndFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.hasSeenKey, true);
    widget.onFinish();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentPage == _pages.length - 1) {
      AnalyticsService().onboardingCompleted();
      _persistAndFinish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _skip() {
    AnalyticsService().onboardingSkipped(_currentPage);
    _persistAndFinish();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background1,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    localizations.onboardingSkip,
                    style: const TextStyle(
                      color: AppColors.labelSecondary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  AnalyticsService().onboardingStepViewed(index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          page.heroAsset,
                          height: 260,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.account_balance_wallet,
                            size: 160,
                            color: AppColors.button,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page.title(localizations),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.label,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description(localizations),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.labelSecondary,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                final selected = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: selected ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.button
                        : AppColors.labelPlaceholder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.button,
                    foregroundColor: AppColors.label,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    isLast
                        ? localizations.onboardingStart
                        : localizations.onboardingNext,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
