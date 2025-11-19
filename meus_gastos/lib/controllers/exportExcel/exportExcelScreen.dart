import 'package:meus_gastos/controllers/exportExcel/export_toExcel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'dart:io';
import 'package:excel/excel.dart';

import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'dart:io';

class Exportexcelscreen extends StatefulWidget {
  final String? category;
  const Exportexcelscreen({Key? key, this.category}) : super(key: key);
  @override
  _Exportexcelscreen createState() => _Exportexcelscreen();
}

class _Exportexcelscreen extends State<Exportexcelscreen> {
  String _selectedFormat = 'Excel';
  bool _isLoadingShare = false;
  bool _isLoadingSaveLocally = false;

  //mark - Loading Indicator
// MARK - Loading Indicator
  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(color: AppColors.label),
    );
  }

  //mark - Build
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: const BoxDecoration(
        color: AppColors.modalBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon:
                      const Icon(CupertinoIcons.clear, color: AppColors.label),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  AppLocalizations.of(context)!.export,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.label),
                ),
                const SizedBox(width: 44),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppLocalizations.of(context)!.textExport,
                style: const TextStyle(color: AppColors.label, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            CupertinoSegmentedControl<String>(
              children: {
                'Excel': Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: const Text('Excel', style: TextStyle(fontSize: 16)),
                ),
                'PDF': Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: const Text('PDF', style: TextStyle(fontSize: 16)),
                ),
                'Texto': Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: const Text('Texto', style: TextStyle(fontSize: 16)),
                ),
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
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _isLoadingShare ? null : _shareData,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.button,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: _isLoadingShare
                          ? Center(child: _buildLoadingIndicator())
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(CupertinoIcons.share,
                                    color: AppColors.label, size: 24),
                                const SizedBox(width: 10),
                                Text(
                                  AppLocalizations.of(context)!.share,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.label,
                                      fontSize: 16),
                                ),
                              ],
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
    );
  }

  //mark - Save Locally
  Future<void> _saveLocally(BuildContext context) async {
    setState(() {
      _isLoadingSaveLocally = true;
    });
    if (_selectedFormat == 'Excel') {
      Excel excel =
          await ExportToExcel.buildExcelFromCards(category: widget.category);
      await ExportToExcel.saveExcelFileLocally(excel, context);
    } else if (_selectedFormat == 'PDF') {
      Excel excel =
          await ExportToExcel.buildExcelFromCards(category: widget.category);
      await ExportToExcel.convertExcelToPdf(excel, context);
    } else {
      await _shareAsText();
    }
    setState(() {
      _isLoadingSaveLocally = false;
    });
  }

  //mark - Share Data
  Future<void> _shareData() async {
    setState(() {
      _isLoadingShare = true;
    });
    if (_selectedFormat == 'Excel') {
      Excel excel =
          await ExportToExcel.buildExcelFromCards(category: widget.category);
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
      Excel excel =
          await ExportToExcel.buildExcelFromCards(category: widget.category);
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

  //mark - Share as Text
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
      await Share.share(message,
          subject: AppLocalizations.of(context)!.shareMensage);
    } catch (e) {
      print('Error sharing text: $e');
    }
  }
}
