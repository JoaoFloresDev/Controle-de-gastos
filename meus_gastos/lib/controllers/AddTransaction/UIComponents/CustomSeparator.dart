import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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