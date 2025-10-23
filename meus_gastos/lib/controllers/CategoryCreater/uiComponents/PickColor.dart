import 'package:flutter/cupertino.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class PickColor {
  void pickColor(BuildContext context, ValueChanged<Color> onColorChange, Color initialColor) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () {},
              child: CupertinoAlertDialog(
                content: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.chooseColor,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ColorPicker(
                        pickerColor: initialColor,
                        onColorChanged: (Color color) {
                          onColorChange(color);
                          initialColor = color;
                        },
                        showLabel: false,
                        pickerAreaHeightPercent: 0.6,
                        displayThumbColor: false,
                        enableAlpha: false,
                        paletteType: PaletteType.hsv,
                        pickerAreaBorderRadius:
                            const BorderRadius.all(Radius.circular(0)),
                      ),
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: CupertinoButton(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(8.0),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.select,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
