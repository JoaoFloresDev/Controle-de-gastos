import 'package:flutter/cupertino.dart';

class HeaderWithGradientBackground extends StatefulWidget {
  final Widget Function(GlobalKey headerKey) headerBuilder;
  const HeaderWithGradientBackground({required this.headerBuilder, super.key});
  @override
  State<HeaderWithGradientBackground> createState() =>
      _HeaderWithGradientBackgroundState();
}

class _HeaderWithGradientBackgroundState
    extends State<HeaderWithGradientBackground> {
  final GlobalKey _headerKey = GlobalKey();
  double _headerHeight = 315;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  @override
  void didUpdateWidget(covariant HeaderWithGradientBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
  }

  void _updateHeight() {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final newHeight = box?.size.height ?? _headerHeight;
    if (newHeight != _headerHeight) {
      setState(() {
        _headerHeight = newHeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sempre agenda a checagem pós-build para capturar updates dinâmicos
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());
    // Obtém o padding do SafeArea
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double topPadding = mediaQuery.padding.top;

    final double totalHeight = topPadding + _headerHeight;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: totalHeight,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: CupertinoColors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          top: true,
          bottom: false,
          child: widget.headerBuilder(_headerKey),
        ),
      ],
    );
  }
}
