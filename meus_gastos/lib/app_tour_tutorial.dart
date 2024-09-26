import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<TargetFocus> addTargetsHearderCard({
  required valueExpens,
  required categories,
  required addButton,
}) {
  List<TargetFocus> targets = [];

  // MARK: value camp
  targets.add(TargetFocus(
      keyTarget: valueExpens,
      identify: "valueExpens",
      radius: 30,
      shape: ShapeLightFocus.RRect,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.valueTutorial,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
            );
          },
        )
      ]));

  // MARK: categorys
  targets.add(TargetFocus(
      keyTarget: categories,
      identify: "categories",
      radius: 30,
      shape: ShapeLightFocus.RRect,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.categoryTutorial,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
            );
          },
        )
      ]));
  // MARK: addButon
  targets.add(TargetFocus(
      keyTarget: addButton,
      radius: 30,
      shape: ShapeLightFocus.RRect,
      enableOverlayTab: true,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              alignment: Alignment.center,
              child: Text(
                AppLocalizations.of(context)!.addExpenseTutorial,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 40),
              ),
            );
          },
        )
      ]));

  return targets;
}

class InAppSave {
  static Future<SharedPreferences> data = SharedPreferences.getInstance();

  static Future<void> saveInsertTransationsStatus() async {
    final value = await data;

    value.setBool("InsertTransactions", true);
  }

  static Future<bool> getInsertTransactionsStatus() async {
    final value = await data;
    if (value.containsKey("InsertTransactions")) {
      bool? getData = value.getBool("InsertTransactions");
      return getData!;
    } else {
      return false;
    }
  }
}
