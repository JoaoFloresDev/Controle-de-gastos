import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

class FinancialKeyboard extends StatelessWidget {
  final Function(String) onNumberPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onConfirmPressed;

  const FinancialKeyboard({
    super.key,
    required this.onNumberPressed,
    required this.onBackspacePressed,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background1,
        border: Border(
          top: BorderSide(color: Colors.white24, width: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toolbar com botão confirmar
          Container(
            height: 50,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white24, width: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  onPressed: onConfirmPressed,
                  child: Text(
                    AppLocalizations.of(context)!.confirm,
                    style: const TextStyle(
                      color: AppColors.label,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Teclado numérico
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Column(
              children: [
                _buildKeyboardRow(['1', '2', '3']),
                const SizedBox(height: 8),
                _buildKeyboardRow(['4', '5', '6']),
                const SizedBox(height: 8),
                _buildKeyboardRow(['7', '8', '9']),
                const SizedBox(height: 8),
                _buildKeyboardRow(['', '0', 'backspace']),
              ],
            ),
          ),
          // Safe area bottom padding
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 8),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) => Expanded(child: _buildKey(key))).toList(),
    );
  }

  Widget _buildKey(String key) {
    if (key == 'backspace') {
      return _KeyButton(
        onPressed: onBackspacePressed,
        child: const Icon(
          CupertinoIcons.delete_left,
          color: AppColors.label,
          size: 28,
        ),
      );
    }

    if (key.isEmpty) {
      return const SizedBox.shrink();
    }

    return _KeyButton(
      onPressed: () => onNumberPressed(key),
      child: Text(
        key,
        style: const TextStyle(
          color: AppColors.label,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _KeyButton({
    required this.onPressed,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class ValorTextField extends StatefulWidget {
  final MoneyMaskedTextController controller;
  final FocusNode? focusNode;
  final VoidCallback? onConfirm;

  const ValorTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.onConfirm,
  });

  @override
  State<ValorTextField> createState() => _ValorTextFieldState();
}

class _ValorTextFieldState extends State<ValorTextField> {
  bool _showClearButton = false;
  bool _showKeyboard = false;
  OverlayEntry? _overlayEntry;
  String _rawValue = '';
  late FocusNode _focusNode; // Adicione isso

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(); // Inicialize o FocusNode
    widget.controller.addListener(_onTextChanged);
    _showClearButton = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.dispose(); // Dispose do FocusNode
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

  void _toggleKeyboard() {
    setState(() {
      _showKeyboard = !_showKeyboard;
    });

    if (_showKeyboard) {
      _focusNode.requestFocus(); // Adicione foco
      _showOverlay();
    } else {
      _focusNode.unfocus(); // Remove foco
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: FinancialKeyboard(
            onNumberPressed: _handleNumberPressed,
            onBackspacePressed: _handleBackspace,
            onConfirmPressed: _handleConfirm,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleNumberPressed(String digit) {
    setState(() {
      _rawValue += digit;
      final cents = int.tryParse(_rawValue) ?? 0;
      final value = cents / 100.0;
      widget.controller.updateValue(value);
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_rawValue.isNotEmpty) {
        _rawValue = _rawValue.substring(0, _rawValue.length - 1);
        
        if (_rawValue.isEmpty) {
          widget.controller.updateValue(0.0);
        } else {
          final cents = int.tryParse(_rawValue) ?? 0;
          final value = cents / 100.0;
          widget.controller.updateValue(value);
        }
      }
    });
  }

  void _handleConfirm() {
    _toggleKeyboard();
    widget.onConfirm?.call();
  }

  void _clearText() {
    setState(() {
      _rawValue = '';
      widget.controller.updateValue(0.0);
    });
  }

@override
Widget build(BuildContext context) {
  return Stack(
    alignment: Alignment.centerRight,
    children: [
      GestureDetector(
        onTap: _toggleKeyboard,
        child: Container(
          color: Colors.transparent, // Para capturar todos os taps
          height: 40,
          child: IgnorePointer(
            child: CupertinoTextField(
              focusNode: _focusNode,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.label)),
              ),
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 20,
              ),
              placeholder: AppLocalizations.of(context)!.enterAmount,
              placeholderStyle: const TextStyle(
                color: AppColors.labelPlaceholder,
                fontSize: 18,
              ),
              controller: widget.controller,
              readOnly: true,
              showCursor: true,
              enableInteractiveSelection: false,
            ),
          ),
        ),
      ),
      if (_showClearButton)
        Positioned(
          right: 0,
          child: GestureDetector(
            onTap: () {
              _clearText();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.transparent, // Para garantir que capture o tap
              child: const Icon(
                CupertinoIcons.clear_circled_solid,
                color: Color.fromARGB(143, 142, 142, 147),
                size: 24,
              ),
            ),
          ),
        ),
    ],
  );
}
}