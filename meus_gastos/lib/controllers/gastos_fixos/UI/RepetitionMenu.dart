import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Components/CustomHeader.dart';
import 'package:meus_gastos/controllers/gastos_fixos/UI/HorizontalCircleList.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import '../CardDetails/DetailScreen.dart';
import 'ListCardFixeds.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class RepetitionMenu extends StatefulWidget {
  final DateTime referenceDate;
  final Function(String selectedRepetition) onRepetitionSelected;
  final String defaultRepetition;

  const RepetitionMenu(
      {super.key,
      required this.referenceDate,
      required this.onRepetitionSelected,
      required this.defaultRepetition});

  @override
  _RepetitionMenuState createState() => _RepetitionMenuState();
}

class _RepetitionMenuState extends State<RepetitionMenu> {
  late String _selectedRepetition = widget.defaultRepetition;

  @override
  void initState() {
    super.initState();
    // _updateRepetitionText();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRepetitionText(context);
    });
  }

  @override
  void didUpdateWidget(RepetitionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza os textos quando a `referenceDate` for alterada
    if (widget.referenceDate != oldWidget.referenceDate) {
      _updateRepetitionText(context);
    }
  }

  void _updateRepetitionText(BuildContext context) {
    final DateFormat dayFormat = DateFormat('d');
    final String dayOfMonth = dayFormat.format(widget.referenceDate);
    print("${widget.defaultRepetition}");
    switch (widget.defaultRepetition) {
      case ('mensal'):
        _selectedRepetition =
            "${AppLocalizations.of(context)!.monthlyEveryDay} $dayOfMonth";
        break;
      case ('semanal'):
        _selectedRepetition =
            "${AppLocalizations.of(context)!.weeklyEvery} ${DateFormat.EEEE('pt_BR').format(widget.referenceDate)}";
        break;
      case ('anual'):
        _selectedRepetition =
            "${AppLocalizations.of(context)!.yearlyEveryDay} ${DateFormat('d MMMM', 'pt_BR').format(widget.referenceDate)}";
        break;
      case ('seg_sex'):
        _selectedRepetition =
            "${AppLocalizations.of(context)!.weekdaysMondayToFriday}";
        break;
      case ('diario'):
        _selectedRepetition = "${AppLocalizations.of(context)!.daily}";
        break;
      default:
        _selectedRepetition =
            "${AppLocalizations.of(context)!.monthlyEveryDay} $dayOfMonth";
        break;
    }
  }

  void _showRepetitionOptions(BuildContext context) {
    final DateFormat dayFormat = DateFormat('d');
    Locale locale = Localizations.localeOf(context);
    String languageCode = locale.languageCode; // Exemplo: 'pt'
    String countryCode = locale.countryCode ?? ''; // Exemplo: 'BR'
    String localeString =
        countryCode.isNotEmpty ? '$languageCode\_$countryCode' : languageCode;
    final DateFormat monthDayFormat = DateFormat('d MMMM', localeString);
    final String dayOfWeek =
        DateFormat.EEEE(localeString).format(widget.referenceDate);
    final String dayOfMonth = dayFormat.format(widget.referenceDate);
    final String monthDay = monthDayFormat.format(widget.referenceDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(AppLocalizations.of(context)!.selectAnOption),
          actions: <Widget>[
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition =
                      "${AppLocalizations.of(context)!.monthlyEveryDay} $dayOfMonth";
                });
                widget.onRepetitionSelected('mensal');
                Navigator.pop(context);
              },
              child: Text(
                  "${AppLocalizations.of(context)!.monthlyEveryDay} $dayOfMonth"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition =
                      "${AppLocalizations.of(context)!.weeklyEvery} $dayOfWeek";
                });
                widget.onRepetitionSelected('semanal');
                Navigator.pop(context);
              },
              child: Text(
                  "${AppLocalizations.of(context)!.weeklyEvery} $dayOfWeek"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition =
                      "${AppLocalizations.of(context)!.yearlyEveryDay} $monthDay";
                });
                widget.onRepetitionSelected('anual');
                Navigator.pop(context);
              },
              child: Text(
                  "${AppLocalizations.of(context)!.yearlyEveryDay} $monthDay"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition =
                      "${AppLocalizations.of(context)!.weekdaysMondayToFriday}";
                });
                widget.onRepetitionSelected('seg_sex');

                Navigator.pop(context);
              },
              child: Text(
                  "${AppLocalizations.of(context)!.weekdaysMondayToFriday}"),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  _selectedRepetition =
                      "${AppLocalizations.of(context)!.daily}";
                });
                widget.onRepetitionSelected('diario');
                Navigator.pop(context);
              },
              child: Text("${AppLocalizations.of(context)!.daily}"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("${AppLocalizations.of(context)!.cancel}"),
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
