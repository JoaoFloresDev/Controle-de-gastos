import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';

class ColorGridSelector extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorGridSelector({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  // Cores pré-definidas organizadas em duas linhas
  static const List<Color> _predefinedColors = [
    // Linha 1
    Color(0xFFFF6B6B), // Vermelho
    Color(0xFFFF8B94), // Rosa claro
    Color(0xFFFFA07A), // Salmão
    Color(0xFFFFD93D), // Amarelo
    Color(0xFFFFC93C), // Dourado
    Color(0xFF95E1D3), // Verde água
    Color(0xFF6BCB77), // Verde
    Color(0xFF4D96FF), // Azul
    Color(0xFF6A5ACD), // Roxo
    Color(0xFFB565D8), // Lilás
    
    // Linha 2
    Color(0xFFE91E63), // Pink
    Color(0xFFFF5722), // Laranja forte
    Color(0xFFFF9800), // Laranja
    Color(0xFFFFC107), // Âmbar
    Color(0xFFCDDC39), // Lima
    Color(0xFF4CAF50), // Verde médio
    Color(0xFF009688), // Teal
    Color(0xFF2196F3), // Azul médio
    Color(0xFF3F51B5), // Indigo
    Color(0xFF9C27B0), // Roxo médio
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88, // Altura para duas linhas de 40px + espaçamento
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          // Primeira linha
          Column(
            children: [
              _buildColorRow(_predefinedColors.sublist(0, 10)),
              const SizedBox(height: 8),
              _buildColorRow(_predefinedColors.sublist(10, 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorRow(List<Color> colors) {
    return Row(
      children: colors.map((color) => _buildColorItem(color)).toList(),
    );
  }

  Widget _buildColorItem(Color color) {
    final isSelected = color.value == selectedColor.value;
    
    return GestureDetector(
      onTap: () {
        onColorSelected(color);
        HapticFeedback.lightImpact();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
            width: isSelected ? 3 : 2,
          ),
        ),
        child: isSelected
            ? const Icon(
                CupertinoIcons.check_mark,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }
}