import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CampoComMascara extends StatefulWidget {
  final String dateText;
  final Function(DateTime) onCompletion;

  CampoComMascara({
    required this.dateText,
    required this.onCompletion,
    Key? key,
  }) : super(key: key);

  @override
  _CampoComMascaraState createState() => _CampoComMascaraState();
}

class _CampoComMascaraState extends State<CampoComMascara> {
  late MaskedTextController _dateController;
  final FocusNode _focusNode = FocusNode();

  // MARK: - InitState
  @override
  void initState() {
    super.initState();
    _dateController = MaskedTextController(mask: '00:00 00/00/0000');
    _dateController.text = widget.dateText;
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _dateController,
      focusNode: _focusNode,
      style: TextStyle(color: CupertinoColors.inactiveGray),
      onTap: _handleTap,
      keyboardType: TextInputType.number,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: CupertinoColors.systemGrey5),
        ),
      ),
      placeholder: AppLocalizations.of(context)!
          .dateFormat, // Utiliza o formato da localização
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
          color: CupertinoColors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                // Formata a data de acordo com a localização
                _dateController.text = _formatDateTime(newDateTime);
                // Chama o callback com o valor de data em formato US/ISO para salvar
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
    final dateFormatPattern = AppLocalizations.of(context)!
        .dateFormat; // Formato de data da localização
    final DateFormat dateFormat = DateFormat(
        dateFormatPattern, Localizations.localeOf(context).toString());
    String formattedDate = dateFormat.format(dateTime);
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $formattedDate';
  }
}
