import 'package:meus_gastos/enums/Category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/models/CardModel.dart';
import 'package:intl/intl.dart';
<<<<<<<< HEAD:meus_gastos/lib/Scenes/InsertTransaction/InsertTransactions/widgets/ListCard.dart
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/widgets/HorizontalCircleList.dart';
========
import 'package:meus_gastos/widgets/Transactions/HorizontalCircleList.dart';
>>>>>>>> 3670368 (Refatoração):meus_gastos/lib/widgets/Transactions/ListCard.dart

class ListCard extends StatelessWidget {
  final CardModel card;
  final Function(CardModel) onTap; // Updated function signature

  ListCard({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(card), // Pass card as a parameter
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(card.amount),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize
                      .min, // Para evitar preencher todo o espaço vertical
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        getIconByCategory(
                          getCategoryByName(
                            card.category.replaceAll("Category.", ""),
                          ),
                        ),
                        size: 18, // Adjust the size as needed
                      ),
                    ),
                    SizedBox(height: 4), // Espaço entre o ícone e o texto
                    Text(
                      getCategoryNameByEnum(
                        getCategoryByName(
                          card.category.replaceAll("Category.", ""),
                        ),
                      ), // Use a função correta para obter o nome da categoria
                      style: TextStyle(
                        fontSize: 9, // Ajuste conforme necessário
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              card.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 2),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                DateFormat('HH:mm dd/MM/yyyy').format(card.date),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(value);
  }
}
