import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'EditionHeaderCard.dart';

class DetailScreen extends StatelessWidget {
  final CardModel card;
  final VoidCallback onAddClicked;

  const DetailScreen({
    required this.onAddClicked,
    Key? key,
    required this.card,
  }) : super(key: key);

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildHeader(context),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: EditionHeaderCard(
                card: card,
                adicionarButtonTitle: 'Atualizar',
                onAddClicked: () {
                  onAddClicked();
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(0),
      child: Container(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCancelButton(context),
            _buildTitle(),
            _buildDeleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text(
        'Cancel',
        style: TextStyle(
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Detalhes da transação',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        CardService.deleteCard(card.id);
        Future.delayed(Duration(milliseconds: 300), () {
          onAddClicked();
          Navigator.of(context).pop();
        });
      },
      icon: Icon(
        Icons.delete,
        color: Colors.red,
      ),
    );
  }
}
