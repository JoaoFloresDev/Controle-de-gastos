import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:io';
import 'package:meus_gastos/l10n/app_localizations.dart';

class ExportToExcel {
  // Função para montar o arquivo Excel a partir dos dados, com filtro opcional de categoria
// MARK - Build Excel From Cards
  static Future<Excel> buildExcelFromCards({String? category}) async {
    List<CardModel> cards = await CardService.retrieveCards();

    if (category != null) {
      cards = cards.where((card) => card.category.name == category).toList();
    }

    cards.sort((a, b) => b.date.compareTo(a.date));

    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    sheetObject.cell(CellIndex.indexByString("A1")).value =
        TextCellValue("Data");
    sheetObject.cell(CellIndex.indexByString("B1")).value =
        TextCellValue("Categoria");
    sheetObject.cell(CellIndex.indexByString("C1")).value =
        TextCellValue("Gasto");
    sheetObject.cell(CellIndex.indexByString("D1")).value =
        TextCellValue("Descrição");

    int i = 2;
    for (var card in cards) {
      String formattedDate =
          '${card.date.day}-${card.date.month.toString().padLeft(2, '0')}-${card.date.year.toString().padLeft(2, '0')}';
      sheetObject.cell(CellIndex.indexByString("A$i")).value =
          TextCellValue(formattedDate);
      sheetObject.cell(CellIndex.indexByString("B$i")).value =
          TextCellValue(card.category.name);
      sheetObject.cell(CellIndex.indexByString("C$i")).value =
          TextCellValue(card.amount.toString());
      sheetObject.cell(CellIndex.indexByString("D$i")).value =
          TextCellValue(card.description);
      i++;
    }

    return excel;
  }

  // Função para salvar o arquivo Excel localmente e abrir
  static Future<void> saveExcelFileLocally(
      Excel excel, BuildContext context) async {
    String? fileName = await _getFileNameFromUser(context, '.xlsx');
    if (fileName == null || fileName.isEmpty) {
      print('Nome do arquivo não fornecido.');
      return;
    }

    // Certifica-se de que o nome do arquivo tem a extensão ".xlsx"
    if (!fileName.endsWith('.xlsx')) {
      fileName += '.xlsx';
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      // O usuário cancelou a seleção
      print('Seleção de pasta cancelada.');
      return;
    }
    String filePath = '$selectedDirectory/$fileName';

    // Salvar o arquivo Excel
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.encode()!);

    // Abrir o arquivo salvo
    final result = await OpenFile.open(filePath);
    print('Resultado da abertura: $result');
    print('Arquivo Excel salvo em: $filePath');
  }

  // Função para montar o PDF a partir do arquivo Excel
  static Future<List<int>> buildPdfFromExcel(Excel excel) async {
    final PdfDocument document = PdfDocument();

    if (excel.tables.isNotEmpty) {
      final sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) return [];

      final PdfPage page = document.pages.add();
      final PdfGrid pdfGrid = PdfGrid();

      // Encontrar o número máximo de colunas e definir a grade do PDF
      int maxCols = sheet.rows
          .fold<int>(0, (prev, row) => row.length > prev ? row.length : prev);
      pdfGrid.columns.add(count: maxCols);

      // Adicionar linhas ao PDF com base nos dados da planilha
      for (final row in sheet.rows) {
        final pdfGridRow = pdfGrid.rows.add();
        for (int i = 0; i < maxCols; i++) {
          pdfGridRow.cells[i].value = row[i]?.value?.toString() ?? '';
        }
      }

      // Ajustar a grade para a largura da página
      pdfGrid.style = PdfGridStyle(
        cellPadding: PdfPaddings(left: 5, right: 5, top: 5, bottom: 5),
        font: PdfStandardFont(PdfFontFamily.helvetica, 12),
      );

      pdfGrid.draw(
        page: page,
        bounds: Rect.fromLTWH(
            0, 0, page.getClientSize().width, page.getClientSize().height),
      );
    }

    final List<int> pdfBytes = await document.save();
    document.dispose();
    return pdfBytes;
  }

  // Função para salvar o PDF localmente
  static Future<void> savePdfLocally(
      List<int> pdfBytes, BuildContext context) async {
    try {
      String? fileName = await _getFileNameFromUser(context, '.pdf');

      if (fileName == null || fileName.isEmpty) {
        print('Nome do arquivo não fornecido.');
        return;
      }

      if (!fileName.endsWith('.pdf')) {
        fileName += '.pdf';
      }

      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        print('Seleção de pasta cancelada.');
        return;
      }

      final filePath = '$selectedDirectory/$fileName';

      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      print('Arquivo salvo em: $filePath');
      final result = await OpenFile.open(filePath);
    } catch (e) {
      print('Erro ao salvar arquivo: $e');
    }
  }

  static Future<String?> _getFileNameFromUser(
      BuildContext context, String extension) async {
    final TextEditingController textController =
        TextEditingController(text: 'sheet_of_expens$extension');

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.modalBackground,
          title: Text(AppLocalizations.of(context)!.savefile,
              style: const TextStyle(color: AppColors.label)),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: AppColors.labelSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(color: AppColors.button)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(textController.text),
              child: Text(AppLocalizations.of(context)!.saveLocally),
            ),
          ],
        );
      },
    );
  }

  // Função para converter o Excel em PDF e salvar localmente
  static Future<void> convertExcelToPdf(
      Excel excel, BuildContext context) async {
    List<int> pdfBytes = await buildPdfFromExcel(excel);
    await savePdfLocally(pdfBytes, context);
  }
}
