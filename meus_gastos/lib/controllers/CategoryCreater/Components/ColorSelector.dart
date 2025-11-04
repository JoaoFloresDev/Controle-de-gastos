import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class ColorSelector extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const ColorSelector({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  void _showColorPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = currentColor;
        
        return Container(
          height: 420,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                AppLocalizations.of(context)!.chooseColor,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ColorPicker(
                pickerColor: tempColor,
                onColorChanged: (Color color) {
                  tempColor = color;
                },
                showLabel: false,
                pickerAreaHeightPercent: 0.6,
                displayThumbColor: false,
                enableAlpha: false,
                paletteType: PaletteType.hsv,
                pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: CupertinoButton(
                  color: AppColors.button,
                  borderRadius: BorderRadius.circular(12),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    onColorChanged(tempColor);
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.select,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.chooseColor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: () {
              _showColorPicker(context);
              HapticFeedback.lightImpact();
            },
            child: Container(
              decoration: BoxDecoration(
                color: currentColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              height: 36,
              width: 36,
              child: Icon(
                CupertinoIcons.eyedropper,
                color: currentColor.computeLuminance() > 0.5 
                    ? Colors.black54 
                    : Colors.white70,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}