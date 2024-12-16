import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Components/CustomHeader.dart';
import 'package:meus_gastos/gastos_fixos/HorizontalCircleList.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import '../CardDetails/DetailScreen.dart';
import '../ListCard.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ValorTextField.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class RepetitionMenu extends StatefulWidget {
  final DateTime referenceDate;
  final Function(String selectedRepetition) onRepetitionSelected;
  final String defaultRepetition;

  const RepetitionMenu(
      {super.key,
      required this.referenceDate,
      required this.onRepetitionSelected,
      required this.defaultRepetition
      });

  @override
  _RepetitionMenuState createState() => _RepetitionMenuState();
}

class _RepetitionMenuState extends State<RepetitionMenu> {
  late String _selectedRepetition = widget.defaultRepetition;

  @override
  void initState() {
    super.initState();
    _updateRepetitionText();
  }

  @override
  void didUpdateWidget(RepetitionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza os textos quando a `referenceDate` for alterada
    if (widget.referenceDate != oldWidget.referenceDate) {
      _updateRepetitionText();
    }
  }

  void _updateRepetitionText() {
    final DateFormat dayFormat = DateFormat('d');
    final String dayOfMonth = dayFormat.format(widget.referenceDate);
    _selectedRepetition = "Mensal: todo dia $dayOfMonth";
  }

  void _showRepetitionOptions(BuildContext context) {
    final DateFormat dayFormat = DateFormat('d');
    final DateFormat monthDayFormat = DateFormat('d MMMM', 'pt_BR');

    final String dayOfWeek =
        DateFormat.EEEE('pt_BR').format(widget.referenceDate);
    final String dayOfMonth = dayFormat.format(widget.referenceDate);
    final String monthDay = monthDayFormat.format(widget.referenceDate);

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text("Selecione uma opção de repetição"),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition = "Mensal: todo dia $dayOfMonth";
                });
                widget.onRepetitionSelected('mensal');
                Navigator.pop(context);
              },
              child: Text("Mensal: todo dia $dayOfMonth"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition = "Semanal: toda $dayOfWeek";
                });
                widget.onRepetitionSelected('semanal');
                Navigator.pop(context);
              },
              child: Text("Semanal: toda $dayOfWeek"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition = "Anual: todo dia $monthDay";
                });
                widget.onRepetitionSelected('anual');
                Navigator.pop(context);
              },
              child: Text("Anual: todo dia $monthDay"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition =
                      "Dias da semana: de segunda a sexta-feira";
                });
                widget.onRepetitionSelected('seg_sex');

                Navigator.pop(context);
              },
              child: const Text("Dias da semana: de segunda a sexta-feira"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition = "Diariamente";
                });
                widget.onRepetitionSelected('diario');
                Navigator.pop(context);
              },
              child: const Text("Diariamente"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancelar"),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: CupertinoButton(
        color: AppColors.card,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        onPressed: () => _showRepetitionOptions(context),
        child: Center(
          child: Text(
            _selectedRepetition,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
