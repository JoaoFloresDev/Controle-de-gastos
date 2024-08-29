import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/widgets/ads_review/bannerAdconstruct.dart';
import 'export_toExcel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Exportexcelscreen extends StatefulWidget {
  Exportexcelscreen({Key? key}) : super(key: key);

  @override
  _Exportexcelscreen createState() => _Exportexcelscreen();
}

class _Exportexcelscreen extends State<Exportexcelscreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
        width: double.maxFinite,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.maxFinite,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            AppLocalizations.of(context)!.cancel,
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(context)!.export,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)!.textExport,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CupertinoButton(
                color: CupertinoColors.systemBlue,
                onPressed: () {
                  ExportToexcel.exportExecel();
                  Navigator.pop(context);
                },
                child: Text(
                  AppLocalizations.of(context)!.export,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(),
            ),
            SizedBox(
              height: 60, // banner height
              width: double.infinity, // banner width
              child: BannerAdconstruct(), // banner widget
            ),
          ],
        ),
      ),
    );
  }
}
