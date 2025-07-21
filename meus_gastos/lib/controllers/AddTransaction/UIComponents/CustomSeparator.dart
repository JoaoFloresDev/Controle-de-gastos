// CustomSeparator.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'Header/HeaderCard.dart';
import 'VerticalCircleList.dart';
import 'CompactListCardRecorrent.dart';
import 'KeyboardDoneToolbar.dart';

class CustomSeparator extends StatelessWidget {
  const CustomSeparator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 1, 24, 8),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withOpacity(0.1),
            Colors.grey.withOpacity(0.5),
            Colors.grey.withOpacity(0.1),
          ],
        ),
      ),
    );
  }
}