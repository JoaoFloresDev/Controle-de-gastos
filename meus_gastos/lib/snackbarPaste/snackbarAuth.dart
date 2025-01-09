import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class CupertinoSnackBar extends StatefulWidget {
  final String message;
  final Duration duration;
  final bool isError;

  const CupertinoSnackBar({
    Key? key,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.isError = true
  }) : super(key: key);

  @override
  _CupertinoSnackBarState createState() => _CupertinoSnackBarState();
}

class _CupertinoSnackBarState extends State<CupertinoSnackBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) Navigator.of(context).pop();
        });
      }
    });
  }

  void _closeSnackBar() {
    _controller.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeSnackBar,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CupertinoPopupSurface(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.card,
                ),
                child: Text(
                  widget.message,
                  style: TextStyle(
                    color: widget.isError ? AppColors.deletionButton : CupertinoColors.systemGreen,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
