import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

//mark - HeaderBar
class HeaderBar extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onDateTap;

  const HeaderBar({
    super.key,
    required this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 20, bottom: 6, top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.registerExpense,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.label,
            ),
          ),
          _buildDateSelector(context),
        ],
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return GestureDetector(
      onTap: onDateTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: ModernColors.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ModernColors.border.withOpacity(0.6),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('HH:mm  dd/MM').format(selectedDate),
              style: const TextStyle(
                color: ModernColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//mark - ModernColors
class ModernColors {
  static const primary = Color(0xFF1F2937);
  static const primaryDark = Color(0xFF111827);
  static const primaryLight = Color(0xFF374151);

  static const accent = Color(0xFF6B7280);
  static const accentDark = Color(0xFF4B5563);
  static const accentLight = Color(0xFF9CA3AF);

  static const backgroundDark = Color(0xFF030712);
  static const backgroundMedium = Color(0xFF0F1419);
  static const surface = Color(0xFF1C2025);
  static const surfaceLight = Color(0xFF24282F);

  static const success = Color(0xFF059669);
  static const successLight = Color(0xFF10B981);
  static const successDark = Color(0xFF047857);

  static const error = Color(0xFFDC2626);
  static const errorLight = Color(0xFFEF4444);
  static const errorDark = Color(0xFFB91C1C);

  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFF59E0B);

  static const textPrimary = Color(0xFFF9FAFB);
  static const textSecondary = Color(0xFFD1D5DB);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textQuaternary = Color(0xFF6B7280);

  static const border = Color(0xFF374151);
  static const borderLight = Color(0xFF4B5563);
  static const borderDark = Color(0xFF1F2937);

  static const overlay = Color(0x60000000);
  static const shadowLight = Color(0x30000000);
  static const shadowMedium = Color(0x40000000);
  static const shadowDark = Color(0x70000000);
}

//mark - HeaderBarContainer
class HeaderBarContainer extends StatefulWidget {
  final VoidCallback onDateTap;
  const HeaderBarContainer({super.key, required this.onDateTap});

  @override
  State<HeaderBarContainer> createState() => _HeaderBarContainerState();
}

class _HeaderBarContainerState extends State<HeaderBarContainer> with WidgetsBindingObserver {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        selectedDate = DateTime.now();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HeaderBar(
      selectedDate: selectedDate,
      onDateTap: () {
        showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        ).then((date) {
          if (date != null) {
            setState(() {
              selectedDate = DateTime(
                date.year,
                date.month,
                date.day,
                selectedDate.hour,
                selectedDate.minute,
              );
            });
          }
        });
        widget.onDateTap();
      },
    );
  }
}
