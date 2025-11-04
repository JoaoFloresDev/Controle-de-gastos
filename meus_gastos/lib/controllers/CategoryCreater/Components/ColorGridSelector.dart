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

  // 40 cores pré-definidas organizadas em duas linhas
  static const List<Color> _predefinedColors = [
    // Linha 1 - Vermelhos, Rosas, Laranjas e Amarelos (20 cores)
    Color(0xFFE63946), // Vermelho intenso
    Color(0xFFFF6B6B), // Vermelho
    Color(0xFFFF8B94), // Rosa claro
    Color(0xFFFF69B4), // Rosa pink
    Color(0xFFE91E63), // Pink
    Color(0xFFFFA07A), // Salmão
    Color(0xFFFF7F50), // Coral
    Color(0xFFFF5722), // Laranja forte
    Color(0xFFFF9800), // Laranja
    Color(0xFFFF6F00), // Laranja escuro
    Color(0xFFFFB74D), // Laranja claro
    Color(0xFFFFD93D), // Amarelo
    Color(0xFFFFC93C), // Dourado
    Color(0xFFFFC107), // Âmbar
    Color(0xFFF9A825), // Amarelo ouro
    Color(0xFFFFEB3B), // Amarelo limão
    Color(0xFFFFEE58), // Amarelo claro
    Color(0xFFFFF176), // Amarelo suave
    Color(0xFFFFE082), // Amarelo pálido
    Color(0xFFFFD54F), // Amarelo mostarda
    
    // Linha 2 - Verdes, Azuis, Roxos e Neutros (20 cores)
    Color(0xFFCDDC39), // Lima
    Color(0xFFAED581), // Verde claro
    Color(0xFF66BB6A), // Verde suave
    Color(0xFF4CAF50), // Verde médio
    Color(0xFF6BCB77), // Verde
    Color(0xFF2E7D32), // Verde escuro
    Color(0xFF26A69A), // Verde azulado
    Color(0xFF009688), // Teal
    Color(0xFF00ACC1), // Ciano
    Color(0xFF0288D1), // Azul claro
    Color(0xFF2196F3), // Azul médio
    Color(0xFF1976D2), // Azul
    Color(0xFF1565C0), // Azul escuro
    Color(0xFF3F51B5), // Indigo
    Color(0xFF5C6BC0), // Indigo claro
    Color(0xFF673AB7), // Roxo profundo
    Color(0xFF9C27B0), // Roxo médio
    Color(0xFFAB47BC), // Roxo
    Color(0xFFBA68C8), // Roxo claro
    Color(0xFFB565D8), // Lilás
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88, // Altura para duas linhas de 40px + espaçamento
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        children: [
          Column(
            children: [
              _buildColorRow(_predefinedColors.sublist(0, 20)),
              const SizedBox(height: 8),
              _buildColorRow(_predefinedColors.sublist(20, 40)),
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