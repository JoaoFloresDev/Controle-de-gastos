import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

class Selectcategorys extends StatefulWidget {
  final List<CategoryModel> categorieList;
  final Function(List<int>) onSelectionChanged;

  const Selectcategorys({
    required this.categorieList,
    required this.onSelectionChanged,
  });

  @override
  SelectcategoryState createState() => SelectcategoryState();
}

class SelectcategoryState extends State<Selectcategorys> {
  Set<int> selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // Inicialmente, todos os itens são selecionados
    selectedIndices =
        Set<int>.from(Iterable<int>.generate(widget.categorieList.length));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60, // Ajuste a altura para acomodar o círculo e o texto
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categorieList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedIndices.contains(index)) {
                      selectedIndices.remove(index);
                    } else {
                      selectedIndices.add(index);
                    }
                  });
                  // Notifica o callback da mudança de seleção
                  widget.onSelectionChanged(selectedIndices.toList());
                },
                child: Column(
                  mainAxisSize: MainAxisSize
                      .min, // Para evitar preencher todo o espaço vertical
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: selectedIndices.contains(index)
                            ? Colors.grey.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.categorieList[index].icon,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.categorieList[index].name,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.categorieList.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedIndices = Set<int>.from(
                        Iterable<int>.generate(widget.categorieList.length));
                  });
                  widget.onSelectionChanged(selectedIndices.toList());
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4), // Ajusta o padding
                  minimumSize:
                      Size(80, 20), // Define um tamanho mínimo para o botão
                  backgroundColor: Colors.transparent,
                ),
                child: Text('Selecionar Todos',
                    style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedIndices = {};
                  });
                  widget.onSelectionChanged([]);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4), // Ajusta o padding
                  minimumSize:
                      Size(80, 20), // Define um tamanho mínimo para o botão
                  backgroundColor: Colors.transparent,
                ),
                child: Text('Limpar',
                    style: TextStyle(
                        fontSize: 12,
                        color: CupertinoColors.systemBlue,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
      ],
    );
  }
}
