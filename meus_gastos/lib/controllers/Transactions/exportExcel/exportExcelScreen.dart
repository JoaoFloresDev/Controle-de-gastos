import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'export_toExcel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io'; // Para salvar localmente

class Exportexcelscreen extends StatefulWidget {
  Exportexcelscreen({Key? key}) : super(key: key);

  @override
  _Exportexcelscreen createState() => _Exportexcelscreen();
}

class _Exportexcelscreen extends State<Exportexcelscreen> {
  String _selectedFormat = 'Excel';

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Ajusta o tamanho para o conteúdo
            children: [
              // Título e botão de cancelar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(CupertinoIcons.clear, color: AppColors.label),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    AppLocalizations.of(context)!.export,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.label,
                    ),
                  ),
                  SizedBox(width: 44), // Espaçamento para balancear o layout
                ],
              ),
              SizedBox(height: 15),
              // Texto explicativo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context)!.textExport,
                  style: TextStyle(color: AppColors.label),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 28),
              // Controle Segmentado
              CupertinoSegmentedControl<String>(
                children: {
                  'Excel': Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 24), // Aumenta o padding
                    child: Text('Excel'),
                  ),
                  'PDF': Container(
                    padding: EdgeInsets.symmetric(
                        vertical: 8, horizontal: 24), // Aumenta o padding
                    child: Text('PDF'),
                  )
                },
                onValueChanged: (value) {
                  setState(() {
                    _selectedFormat = value;
                  });
                },
                groupValue: _selectedFormat,
                selectedColor: AppColors.button,
                unselectedColor: AppColors.buttonDeselected,
                borderColor: AppColors.button,
              ),

              SizedBox(height: 30),
              // Botões de Ação (um abaixo do outro)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _saveLocally,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.cloud_download,
                                  color: AppColors.label),
                              SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.saveLocally,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.label,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 22), // Espaçamento entre os botões
                    GestureDetector(
                      onTap: _shareViaWhatsApp,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(CupertinoIcons.share,
                                  color: AppColors.label),
                              SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.share,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.label,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _saveLocally() async {
    Excel excel = await ExportToExcel.buildExcelFromCards();
    if (_selectedFormat == 'Excel') {
      ExportToExcel.saveExcelFileLocally(
          excel); // Substitua por seu método de exportação
    } else {
      await ExportToExcel.convertExcelToPdf(
          excel); // Substitua por seu método de exportação para PDF
    }
    // Implemente lógica para salvar localmente
  }

  void _shareViaWhatsApp() async {
    void _shareViaWhatsApp() async {
      // Caminho onde o arquivo será salvo
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '';

      if (_selectedFormat == 'Excel') {
        // Construir o arquivo Excel
        Excel excel = await ExportToExcel.buildExcelFromCards();

        // Definir o caminho do arquivo Excel
        filePath = '${directory.path}/sheet_of_expens.xlsx';

        // Salvar o Excel localmente
        File(filePath)
          ..createSync(recursive: true)
          ..writeAsBytesSync(excel.encode()!);
      } else if (_selectedFormat == 'PDF') {
        // Construir o arquivo Excel para gerar o PDF
        Excel excel = await ExportToExcel.buildExcelFromCards();

        // Criar o PDF a partir do Excel
        List<int> pdfBytes = await ExportToExcel.buildPdfFromExcel(excel);

        // Definir o caminho do arquivo PDF
        filePath = '${directory.path}/sheet_of_expens.pdf';

        // Salvar o PDF localmente
        File(filePath).writeAsBytesSync(pdfBytes);
      } else {
        print('Formato não suportado para compartilhamento.');
        return;
      }

      // Compartilhar o arquivo usando o pacote Share Plus
      try {
        await Share.shareXFiles(
          [XFile(filePath)],
          text:
              '${AppLocalizations.of(context)!.shareMensage}: https://play.google.com/store/apps/details?id=meus_gastos.my_expenses&pcampaignid=web_share',
          sharePositionOrigin: Rect.fromLTWH(0, 0, 1, 1),
        );
        print('Arquivo compartilhado com sucesso!');
      } catch (e) {
        print('Erro ao compartilhar o arquivo: $e');
      }
    }
  }
}
