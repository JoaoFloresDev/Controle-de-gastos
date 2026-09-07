import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

/// Keyboard bindings for the macOS build.
///
/// Sits above the whole shell so it keeps working while a text field holds
/// focus — ⌘+digit is not consumed by CupertinoTextField, so the binding
/// bubbles up from the focused node to here.
class DesktopShortcuts extends StatelessWidget {
  /// Called with the tab index to open (0-based).
  final ValueChanged<int> onSelectTab;

  /// Index of the tab that creates a transaction (⌘N).
  final int addTabIndex;

  /// Index of the settings tab (⌘,) — the macOS convention for preferences.
  final int settingsTabIndex;

  final Widget child;

  const DesktopShortcuts({
    super.key,
    required this.onSelectTab,
    required this.addTabIndex,
    required this.settingsTabIndex,
    required this.child,
  });

  // MARK: - Build

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        for (final entry in _digitKeys.asMap().entries)
          SingleActivator(entry.value, meta: true): () =>
              onSelectTab(entry.key),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            onSelectTab(addTabIndex),
        const SingleActivator(LogicalKeyboardKey.comma, meta: true): () =>
            onSelectTab(settingsTabIndex),
      },
      child: Focus(autofocus: true, child: child),
    );
  }

  // MARK: - Keys

  static const List<LogicalKeyboardKey> _digitKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
  ];
}
