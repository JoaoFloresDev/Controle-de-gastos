import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ExportToExcel {
  // Função para montar o arquivo Excel a partir dos dados
  static Future<Excel> buildExcelFromCards() async {
    List<CardModel> cards = await CardService.retrieveCards();
    // Ordenar os cards por data (do mais recente para o mais antigo)
    cards.sort((a, b) => b.date.compareTo(a.date));

    // Criar o documento Excel
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Definir os cabeçalhos das colunas
    sheetObject.cell(CellIndex.indexByString("A1")).value =
        TextCellValue("Data");
    sheetObject.cell(CellIndex.indexByString("B1")).value =
        TextCellValue("Categoria");
    sheetObject.cell(CellIndex.indexByString("C1")).value =
        TextCellValue("Gasto");

    // Adicionar os dados dos cards
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
      i++;
    }

    return excel;
  }

  // Função para salvar o arquivo Excel localmente e abrir
  static Future<void> saveExcelFileLocally(Excel excel) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/sheet_of_expens.xlsx';

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
    // Criar um documento PDF
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

    // Salvar o documento em bytes
    final List<int> pdfBytes = await document.save();
    document.dispose();
    return pdfBytes;
  }

  // Função para salvar o PDF localmente
  static Future<void> savePdfLocally(List<int> pdfBytes) async {
    try {
      // Obtém o diretório de documentos do aplicativo
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/sheet_of_expens.pdf';

      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      print('PDF salvo em: $filePath');
    } catch (e) {
      print('Erro ao salvar o PDF: $e');
    }
  }

  // Função principal para converter o Excel em PDF
  static Future<void> convertExcelToPdf(Excel excel) async {
    // Monta o PDF a partir do arquivo Excel
    List<int> pdfBytes = await buildPdfFromExcel(excel);

    // Salva o arquivo localmente
    await savePdfLocally(pdfBytes);
  }
}
