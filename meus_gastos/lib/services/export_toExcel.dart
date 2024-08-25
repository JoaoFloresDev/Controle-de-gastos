import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:open_filex/open_filex.dart';

class ExportToexcel {
  static void exportExecel() async {
    List<CardModel> cards = await CardService.retrieveCards();
    cards.sort((a, b) => b.date.compareTo(a.date));
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.cell(CellIndex.indexByString("A1")).value = TextCellValue("ID");
    sheetObject.cell(CellIndex.indexByString("B1")).value =
        TextCellValue("Date");
    sheetObject.cell(CellIndex.indexByString("C1")).value =
        TextCellValue("Category");
    sheetObject.cell(CellIndex.indexByString("D1")).value =
        TextCellValue("Expens");
    int i = 2;
    for (var card in cards) {
      sheetObject.cell(CellIndex.indexByString("A$i")).value =
          TextCellValue(card.id);
      sheetObject.cell(CellIndex.indexByString("B$i")).value = DateCellValue(
          year: card.date.year, month: card.date.month, day: card.date.day);
      sheetObject.cell(CellIndex.indexByString("C$i")).value =
          TextCellValue(card.category.name);
      sheetObject.cell(CellIndex.indexByString("D$i")).value =
          TextCellValue(card.amount.toString());
      i++;
    }
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/sheet_of_expens.xlsx';

    // Salve o arquivo
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);
    final result = await OpenFilex.open(filePath);

    print('Resultado da abertura: $result');
    print('Arquivo Excel salvo em: $filePath');
  }
}
