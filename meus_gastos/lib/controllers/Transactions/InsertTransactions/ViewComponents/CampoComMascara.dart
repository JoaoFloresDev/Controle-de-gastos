import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/exportDS.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CampoComMascara extends StatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onCompletion;

  CampoComMascara({
    required this.currentDate,
    required this.onCompletion,
    Key? key,
  }) : super(key: key);

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
    // Não acessar o contexto aqui
    // _dateFormatPattern será configurado no didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Acessar o contexto aqui
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
      style: TextStyle(color: CupertinoColors.inactiveGray),
      onTap: _handleTap,
      keyboardType: TextInputType.datetime,
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
            initialDateTime: widget.currentDate,
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
    if (_dateFormatPattern == null) {
      return ''; // Retorna uma string vazia se o formato não estiver disponível
    }
    final DateFormat dateFormat = DateFormat(
        _dateFormatPattern!, Localizations.localeOf(context).toString());
    String formattedDate = dateFormat.format(dateTime);
    return '$formattedDate';
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
