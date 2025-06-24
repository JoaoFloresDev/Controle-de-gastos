import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class ValorTextField extends StatefulWidget {
  final MoneyMaskedTextController controller;

  const ValorTextField({super.key, required this.controller});

  @override
  State<ValorTextField> createState() => _ValorTextFieldState();
}

class _ValorTextFieldState extends State<ValorTextField> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // Monitora mudanças no controller para mostrar/esconder o botão clear
    widget.controller.addListener(_onTextChanged);
    _showClearButton = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final shouldShow = widget.controller.text.isNotEmpty;
    if (shouldShow != _showClearButton) {
      setState(() {
        _showClearButton = shouldShow;
      });
    }
  }

  void _clearText() {
    widget.controller.updateValue(0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      child: CupertinoTextField(
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.label)),
        ),
        style: const TextStyle(color: AppColors.label),
        placeholder: AppLocalizations.of(context)!.enterAmount,
        placeholderStyle: const TextStyle(color: AppColors.labelPlaceholder),
        keyboardType: TextInputType.number,
        controller: widget.controller,
        suffix: _showClearButton
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                minSize: 20,
                onPressed: _clearText,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: const Color.fromARGB(143, 142, 142, 147),
                    size: 24,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}