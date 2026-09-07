import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

/// One entry of the macOS sidebar.
class DesktopNavItem {
  final IconData icon;
  final String label;

  /// Shown right-aligned, e.g. "⌘1". Purely a hint — the binding itself lives
  /// in [DesktopShortcuts].
  final String shortcut;

  const DesktopNavItem({
    required this.icon,
    required this.label,
    required this.shortcut,
  });
}

/// Vertical navigation for the desktop build.
///
/// The mobile build keeps its bottom tab bar; on a Mac window a bottom bar
/// sits 800px away from where the eye is and wastes the width the desktop
/// actually has.
class DesktopSidebar extends StatelessWidget {
  static const double width = 232;

  final List<DesktopNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String title;

  const DesktopSidebar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.title,
  });

  // MARK: - Build

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF161C24), Color(0xFF0F141A)],
        ),
        border: Border(
          right: BorderSide(color: Color(0xFF23272E), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leaves room for the traffic-light buttons of the transparent title bar.
          const SizedBox(height: 34),
          _buildTitle(),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: items.length,
              itemBuilder: (context, index) => _DesktopSidebarItem(
                item: items[index],
                isSelected: index == selectedIndex,
                onTap: () => onSelected(index),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Sections

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 0, 18, 0),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.label,
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

/// A single row, with the hover feedback a desktop user expects.
class _DesktopSidebarItem extends StatefulWidget {
  final DesktopNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DesktopSidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DesktopSidebarItem> createState() => _DesktopSidebarItemState();
}

class _DesktopSidebarItemState extends State<_DesktopSidebarItem> {
  bool _isHovered = false;

  // MARK: - Build

  @override
  Widget build(BuildContext context) {
    final Color background = widget.isSelected
        ? AppColors.button.withOpacity(0.18)
        : (_isHovered ? const Color(0x14FFFFFF) : const Color(0x00000000));
    final Color foreground =
        widget.isSelected ? AppColors.label : AppColors.labelSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          margin: const EdgeInsets.symmetric(vertical: 3),
          // 44pt minimum touch/click target (RULES).
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.button.withOpacity(0.45)
                  : const Color(0x00000000),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 19, color: foreground),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              Text(
                widget.item.shortcut,
                style: const TextStyle(
                  color: AppColors.labelPlaceholder,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
