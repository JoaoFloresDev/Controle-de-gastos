import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRepetitionText(context);
    });
  }

  @override
  void didUpdateWidget(RepetitionMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    String languageCode = locale.languageCode;
    String countryCode = locale.countryCode ?? '';
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
                  "${AppLocalizations.of(context)!.monthlyEveryDay} $dayOfMonth",
                  style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: CupertinoColors.white,
                          ),
                          ),
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
                  "${AppLocalizations.of(context)!.weeklyEvery} $dayOfWeek",                  style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: CupertinoColors.white,
                          ),),
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
                  "${AppLocalizations.of(context)!.yearlyEveryDay} $monthDay",                  style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: CupertinoColors.white,
                          ),),
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
                  "${AppLocalizations.of(context)!.weekdaysMondayToFriday}",                  style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: CupertinoColors.white,
                          ),),
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
              child: Text("${AppLocalizations.of(context)!.daily}",style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                            color: CupertinoColors.white,
                          )),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: CupertinoColors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRepetitionOptions(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBlue.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.repeat,
                color: CupertinoColors.systemBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedRepetition,
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: CupertinoColors.white.withOpacity(0.3),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}