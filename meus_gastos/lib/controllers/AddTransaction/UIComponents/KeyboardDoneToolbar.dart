import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

class KeyboardDoneToolbar extends StatelessWidget {
  final VoidCallback onDone;
  const KeyboardDoneToolbar({required this.onDone, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background1,
        border: Border(
          top: BorderSide(color: Colors.white24, width: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.only(right: 24),
            onPressed: onDone,
            child: const Text(
              'Confirmar',
              style: TextStyle(
                color: AppColors.label,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
