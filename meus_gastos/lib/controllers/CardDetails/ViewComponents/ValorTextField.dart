// import 'dart:io' show Platform;
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_masked_text2/flutter_masked_text2.dart';
// import 'package:meus_gastos/designSystem/ImplDS.dart';
// import 'CustomButton.dart';
// import 'package:meus_gastos/l10n/app_localizations.dart';

// class ValorTextField extends StatefulWidget {
//   final MoneyMaskedTextController controller;

//   const ValorTextField({super.key, required this.controller});

//   @override
//   _ValorTextFieldState createState() => _ValorTextFieldState();
// }

// class _ValorTextFieldState extends State<ValorTextField> {
//   final FocusNode _focusNode = FocusNode();
//   OverlayEntry? _overlayEntry;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoTextField(
//       focusNode: _focusNode,
//       decoration: const BoxDecoration(
//         border: Border(bottom: BorderSide(color: AppColors.label)),
//       ),
//       style: const TextStyle(color: AppColors.label),
//       placeholder: AppLocalizations.of(context)!.enterAmount, // Placeholder
//       placeholderStyle: const TextStyle(color: AppColors.labelPlaceholder),
//       keyboardType: TextInputType.number,
//       controller: widget.controller,
//     );
//   }

//   @override
//   void dispose() {
//     _focusNode.unfocus();
//     // _focusNode.removeListener(_handleFocusChange);
//     _focusNode.dispose();
//     _overlayEntry?.remove();
//     super.dispose();
//   }
// }