import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class CampoComMascara extends StatefulWidget {
  final String dateText;
  final Function(DateTime) onCompletion;
  CampoComMascara(
      {required this.dateText, required this.onCompletion, Key? key})
      : super(key: key);

  @override
  _CampoComMascaraState createState() => _CampoComMascaraState();
}

class _CampoComMascaraState extends State<CampoComMascara> {
  final _dateController = MaskedTextController(mask: '00/00/00 00:00');

  @override
  void initState() {
    super.initState();
    _dateController.text = widget.dateText;
  }

  FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _dateController,
      focusNode: _focusNode,
      style: TextStyle(color: CupertinoColors.inactiveGray),
      onTap: () {
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
                    _dateController.text = _formatDateTime(newDateTime);
                    widget.onCompletion(newDateTime);
                  });
                },
              ),
            );
          },
        );
      },
      keyboardType: TextInputType.number,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: CupertinoColors.systemGrey5)),
      ),
      placeholder: 'DD/MM/AA HH:mm',
    );
  }

  String _formatDateTime(DateTime dateTime) {
    String formattedDate =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year.toString().substring(2)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedDate;
  }
}
