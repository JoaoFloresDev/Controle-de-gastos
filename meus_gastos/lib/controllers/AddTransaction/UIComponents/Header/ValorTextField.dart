import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import '../../../../designSystem/FinancialKeyboard.dart';

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
  State<ValorTextField> createState() => ValorTextFieldState();
}

class ValorTextFieldState extends State<ValorTextField> with SingleTickerProviderStateMixin {
  bool _showClearButton = false;
  bool _showKeyboard = false;
  OverlayEntry? _overlayEntry;
  String _rawValue = '';
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
    _showClearButton = widget.controller.text.isNotEmpty;

    final numeric = widget.controller.numberValue;
    if (numeric > 0) {
      _rawValue = (numeric * 100).round().toString();
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _animationController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  // MARK: - Public Methods

  void clear() {
    setState(() {
      _rawValue = '';
      widget.controller.updateValue(0.0);
      _showClearButton = false;
    });
  }

  // MARK: - Private Methods

  void _onFocusChanged() {
    if (!_focusNode.hasFocus && _showKeyboard) {
      _hideKeyboard();
    }
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
    if (_showKeyboard) {
      _hideKeyboard();
    } else {
      _showKeyboardWithAnimation();
    }
  }

  void _showKeyboardWithAnimation() {
    final numeric = widget.controller.numberValue;
    _rawValue = (numeric * 100).round().toString();

    setState(() {
      _showKeyboard = true;
    });
    _focusNode.requestFocus();
    _showOverlay();
    _animationController.forward();
  }

  Future<void> _hideKeyboard() async {
    await _animationController.reverse();
    setState(() {
      _showKeyboard = false;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _removeOverlay();
      if (_focusNode.hasFocus) _focusNode.unfocus();
    });
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: FinancialKeyboard(
              onNumberPressed: _handleNumberPressed,
              onBackspacePressed: _handleBackspace,
              onConfirmPressed: _handleConfirm,
            ),
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
      widget.controller.updateValue(cents / 100.0);
    });
  }

  void _handleBackspace() {
    setState(() {
      if (_rawValue.isNotEmpty) {
        _rawValue = _rawValue.substring(0, _rawValue.length - 1);
      }
      final cents = int.tryParse(_rawValue.isEmpty ? '0' : _rawValue) ?? 0;
      widget.controller.updateValue(cents / 100.0);
    });
  }

  void _handleConfirm() {
    final cents = int.tryParse(_rawValue) ?? 0;
    widget.controller.updateValue(cents / 100.0);
    _rawValue = (widget.controller.numberValue * 100).round().toString();
    _hideKeyboard();
    widget.onConfirm?.call();
  }

  void _clearText() {
    clear();
  }

  // MARK: - Build

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: _toggleKeyboard,
          child: Container(
            color: Colors.transparent,
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
              onTap: _clearText,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.transparent,
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
