import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter/material.dart';
import 'CampoComMascara.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meus_gastos/enums/Category.dart';

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;

  const HorizontalCircleList({
    Key? key,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _HorizontalCircleListState createState() => _HorizontalCircleListState();
}

class _HorizontalCircleListState extends State<HorizontalCircleList> {
  int selectedIndex = 0;
  int lastSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Ajuste a altura para acomodar o círculo e o texto
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: Category.values.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                lastSelectedIndex = selectedIndex;
                selectedIndex = index;
              });
              widget.onItemSelected(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Para evitar preencher todo o espaço vertical
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Colors.green.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CategoryInfo.getByCategory(Category.values[index]).icon,
                    // getIconByCategory(Category.values[index]),
                  ),
                ),
                SizedBox(height: 4), // Espaço entre o ícone e o texto
                Text(
                  CategoryInfo.getByCategory(Category.values[index]).name,
                  style: TextStyle(
                    fontSize: 9, // Ajuste conforme necessário
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
