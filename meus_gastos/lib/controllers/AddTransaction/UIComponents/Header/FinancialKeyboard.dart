
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_masked_text2/flutter_masked_text2.dart';
// import 'package:meus_gastos/designSystem/ImplDS.dart';
// import 'package:meus_gastos/l10n/app_localizations.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
// import 'package:meus_gastos/l10n/app_localizations.dart';

// class FinancialKeyboard extends StatelessWidget {
//   final Function(String) onNumberPressed;
//   final VoidCallback onBackspacePressed;
//   final VoidCallback onConfirmPressed;

//   const FinancialKeyboard({
//     super.key,
//     required this.onNumberPressed,
//     required this.onBackspacePressed,
//     required this.onConfirmPressed,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).padding.bottom;
    
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.background1,
//         border: Border(
//           top: BorderSide(color: Colors.white24, width: 0.3),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Toolbar com botão confirmar
//           Container(
//             height: 50,
//             decoration: const BoxDecoration(
//               border: Border(
//                 bottom: BorderSide(color: Colors.white24, width: 0.3),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CupertinoButton(
//                   padding: const EdgeInsets.symmetric(horizontal: 24),
//                   onPressed: onConfirmPressed,
//                   child: Text(
//                     AppLocalizations.of(context)!.confirm,
//                     style: const TextStyle(
//                       color: AppColors.label,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Teclado numérico
//           Container(
//             padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
//             child: Column(
//               children: [
//                 _buildKeyboardRow(['1', '2', '3']),
//                 const SizedBox(height: 8),
//                 _buildKeyboardRow(['4', '5', '6']),
//                 const SizedBox(height: 8),
//                 _buildKeyboardRow(['7', '8', '9']),
//                 const SizedBox(height: 8),
//                 _buildKeyboardRow(['', '0', 'backspace']),
//               ],
//             ),
//           ),
//           // Safe area bottom padding
//           SizedBox(height: bottomPadding > 0 ? bottomPadding : 8),
//         ],
//       ),
//     );
//   }

//   Widget _buildKeyboardRow(List<String> keys) {
//     return Row(
//       children: keys.map((key) => Expanded(child: _buildKey(key))).toList(),
//     );
//   }

//   Widget _buildKey(String key) {
//     if (key == 'backspace') {
//       return _KeyButton(
//         onPressed: onBackspacePressed,
//         child: const Icon(
//           CupertinoIcons.delete_left,
//           color: AppColors.label,
//           size: 28,
//         ),
//       );
//     }

//     if (key.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return _KeyButton(
//       onPressed: () => onNumberPressed(key),
//       child: Text(
//         key,
//         style: const TextStyle(
//           color: AppColors.label,
//           fontSize: 24,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//     );
//   }
// }

// class _KeyButton extends StatelessWidget {
//   final VoidCallback onPressed;
//   final Widget child;

//   const _KeyButton({
//     required this.onPressed,
//     required this.child,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: CupertinoButton(
//         padding: EdgeInsets.zero,
//         onPressed: onPressed,
//         child: Container(
//           height: 56,
//           decoration: BoxDecoration(
//             color: AppColors.card,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Center(child: child),
//         ),
//       ),
//     );
//   }
// }