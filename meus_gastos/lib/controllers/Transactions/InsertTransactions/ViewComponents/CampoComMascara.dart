import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class CampoComMascara extends StatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onCompletion;

  const CampoComMascara({
    required this.currentDate,
    required this.onCompletion,
    super.key,
  });

  @override
  _CampoComMascaraState createState() => _CampoComMascaraState();
}

class _CampoComMascaraState extends State<CampoComMascara> {
  late TextEditingController _dateController;
  final FocusNode _focusNode = FocusNode();
  String? _dateFormatPattern;

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dateFormatPattern =
        AppLocalizations.of(context)?.dateFormat ?? 'dd/MM/yyyy';
    _dateController =
        TextEditingController(text: _formatDateTime(widget.currentDate));
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _dateController,
      focusNode: _focusNode,
      style: const TextStyle(color: AppColors.labelPlaceholder),
      onTap: _handleTap, // Desativa o picker para macOS
      keyboardType: TextInputType.datetime,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.line),
        ),
      ),
      placeholder: AppLocalizations.of(context)!.dateFormat,
    );
  }

  // MARK: - Handle Tap
  void _handleTap() {
    _focusNode.unfocus();
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          color: AppColors.label,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: widget.currentDate,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                _dateController.text = _formatDateTime(newDateTime);
                widget.onCompletion(newDateTime);
              });
            },
          ),
        );
      },
    );
  }

  // MARK: - Format DateTime para exibição (de acordo com o AppLocalizations)
  String _formatDateTime(DateTime dateTime) {
    if (_dateFormatPattern == null) {
      return '';
    }
    final DateFormat dateFormat = DateFormat(
        _dateFormatPattern!, Localizations.localeOf(context).toString());
    String formattedDate = dateFormat.format(dateTime);
    return formattedDate;
  }

  // MARK: - Format String para DateTime
  String _formatDateTimeFromString(String dateText) {
    final DateFormat formatter = DateFormat('HH:mm dd/MM/yyyy');
    try {
      final DateTime dateTime = formatter.parse(dateText);
      return _formatDateTime(dateTime);
    } catch (e) {
      return '';
    }
  }
}
