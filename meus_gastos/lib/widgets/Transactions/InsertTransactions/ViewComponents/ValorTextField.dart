import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter/material.dart';
import 'CustomButton.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ValorTextField extends StatefulWidget {
  final MoneyMaskedTextController controller;

  ValorTextField({required this.controller});

  @override
  _ValorTextFieldState createState() => _ValorTextFieldState();
}

class _ValorTextFieldState extends State<ValorTextField> {
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    
    if (_focusNode.hasFocus) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeOverlay();
    }
  }
  OverlayEntry _createOverlayEntry() {
    final screenWidth = MediaQuery.of(context).size.width;
    return OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        width: screenWidth,
        child: KeyboardAccessory(add: (int value) {
          widget.controller.updateValue(widget.controller.numberValue + value);
        }, sub: (int value) {
          double result = widget.controller.numberValue - value;
          if (result > 0) {
            widget.controller.updateValue(result);
          } else {
            widget.controller.updateValue(0.0);
          }
        }),
      ),
    );
  }
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      focusNode: _focusNode,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey)),
      ),
      style:
          const TextStyle(color: Colors.white),
      placeholder: AppLocalizations.of(context)!.enterAmount, // Placeholder
      placeholderStyle: TextStyle(
          color: Colors.white.withOpacity(
              0.6)),
      keyboardType: TextInputType.number,
      controller: widget.controller,
    );
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }
}

class KeyboardAccessory extends StatelessWidget {
  final ValueChanged<int> add;
  final ValueChanged<int> sub;

  const KeyboardAccessory({Key? key, required this.add, required this.sub})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.black,
      height: 140,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (var value in [5, 10, 20, 50, 100])
                  CustomButton(
                    text: '+$value',
                    onPressed: () => add(value),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                for (var value in [5, 10, 20, 50, 100])
                  CustomButton2(
                    text: '-$value',
                    onPressed: () => sub(value),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
