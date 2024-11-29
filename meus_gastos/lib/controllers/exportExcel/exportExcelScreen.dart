import 'package:meus_gastos/controllers/exportExcel/export_toExcel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';
import 'package:excel/excel.dart';

class Exportexcelscreen extends StatefulWidget {
  final String? category;
  const Exportexcelscreen({super.key, this.category});

  @override
  _Exportexcelscreen createState() => _Exportexcelscreen();
}

class _Exportexcelscreen extends State<Exportexcelscreen> {
  String _selectedFormat = 'Excel';
  bool _isLoadingShare = false;
  bool _isLoadingSaveLocally = false;

  Widget _buildLoadingIndicator() {
    return const CircularProgressIndicator(color: AppColors.label);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: double.maxFinite,
        decoration: const BoxDecoration(
          color: AppColors.modalBackground,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(CupertinoIcons.clear,
                        color: AppColors.label),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    AppLocalizations.of(context)!.export,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.label,
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  AppLocalizations.of(context)!.textExport,
                  style: const TextStyle(color: AppColors.label),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              CupertinoSegmentedControl<String>(
                children: {
                  'Excel': Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: const Text('Excel'),
                  ),
                  'PDF': Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: const Text('PDF'),
                  ),
                  'Texto': Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: const Text('Texto'),
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
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isLoadingSaveLocally
                          ? null
                          : () => _saveLocally(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: _isLoadingSaveLocally
                              ? _buildLoadingIndicator()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(CupertinoIcons.cloud_download,
                                        color: AppColors.label),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.saveLocally,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.label,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    GestureDetector(
                      onTap: _isLoadingShare ? null : _shareData,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.button,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: _isLoadingShare
                              ? _buildLoadingIndicator()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(CupertinoIcons.share,
                                        color: AppColors.label),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.share,
                                      style: const TextStyle(
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveLocally(BuildContext context) async {
    setState(() {
      _isLoadingSaveLocally = true;
    });

    if (_selectedFormat == 'Excel') {
      Excel excel = await ExportToExcel.buildExcelFromCards(
        category: widget.category,
      );
      await ExportToExcel.saveExcelFileLocally(excel, context);
    } else if (_selectedFormat == 'PDF') {
      Excel excel = await ExportToExcel.buildExcelFromCards(
        category: widget.category,
      );
      await ExportToExcel.convertExcelToPdf(excel, context);
    } else {
      await _shareAsText();
    }

    setState(() {
      _isLoadingSaveLocally = false;
    });
  }

  Future<void> _shareData() async {
    setState(() {
      _isLoadingShare = true;
    });

    if (_selectedFormat == 'Excel') {
      Excel excel = await ExportToExcel.buildExcelFromCards(
        category: widget.category,
      );

      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/sheet_of_expens.xlsx';

      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: AppLocalizations.of(context)!.shareMensage,
      );
    } else if (_selectedFormat == 'PDF') {
      Excel excel = await ExportToExcel.buildExcelFromCards(
        category: widget.category,
      );
      List<int> pdfBytes = await ExportToExcel.buildPdfFromExcel(excel);

      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = '${directory.path}/sheet_of_expens.pdf';

      File(filePath).writeAsBytesSync(pdfBytes);

      await Share.shareXFiles(
        [XFile(filePath)],
        text: AppLocalizations.of(context)!.shareMensage,
      );
    } else {
      await _shareAsText();
    }

    setState(() {
      _isLoadingShare = false;
    });
  }

  Future<void> _shareAsText() async {
    try {
      List<CardModel> cards = await CardService.retrieveCards();
      if (widget.category != null) {
        cards = cards
            .where((card) => card.category.name == widget.category)
            .toList();
      }

      String message = '${AppLocalizations.of(context)!.shareMensage}\n\n';
      message += cards.map((card) {
        return '${card.date.toLocal().toString().split(' ')[0]}\t${card.category.name}\tR\$ ${card.amount.toStringAsFixed(2)}';
      }).join('\n');

      await Share.share(
        message,
        subject: AppLocalizations.of(context)!.shareMensage,
      );
    } catch (e) {
      print('Erro ao compartilhar mensagem de texto: $e');
    }
  }
}
