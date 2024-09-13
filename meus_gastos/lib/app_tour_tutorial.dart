import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<TargetFocus> addTargetsHearderCard(
    {required valueExpens,
    required date,
    required description,
    required categories,
    required addButton,
    required dashboardTab,
    required cardsExpens,
    required exportButon}) {
  List<TargetFocus> targets = [];

  // MARK: value camp
  targets.add(TargetFocus(
      keyTarget: valueExpens,
      alignSkip: Alignment.bottomRight,
      radius: 30,
      shape: ShapeLightFocus.RRect,
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
  // // MARK: date
  // targets.add(TargetFocus(
  //     keyTarget: date,
  //     alignSkip: Alignment.bottomLeft,
  //     radius: 20,
  //     shape: ShapeLightFocus.RRect,
  //     contents: [
  //       TargetContent(
  //         align: ContentAlign.bottom,
  //         builder: (context, controller) {
  //           return Container(
  //             alignment: Alignment.center,
  //             child: Text(
  //               AppLocalizations.of(context)!.dateTutorial,
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 40),
  //             ),
  //           );
  //         },
  //       )
  //     ]));
  // // MARK: description
  // targets.add(TargetFocus(
  //     keyTarget: description,
  //     alignSkip: Alignment.bottomCenter,
  //     radius: 20,
  //     shape: ShapeLightFocus.RRect,
  //     contents: [
  //       TargetContent(
  //         align: ContentAlign.bottom,
  //         builder: (context, controller) {
  //           return Container(
  //             alignment: Alignment.center,
  //             child: Text(
  //               AppLocalizations.of(context)!.commentTutorial,
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 40),
  //             ),
  //           );
  //         },
  //       )
  //     ]));
  // MARK: categorys
  targets.add(TargetFocus(
      keyTarget: categories,
      alignSkip: Alignment.bottomCenter,
      radius: 30,
      shape: ShapeLightFocus.RRect,
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
      alignSkip: Alignment.bottomCenter,
      radius: 30,
      shape: ShapeLightFocus.RRect,
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
  // MARK: cards list
  // targets.add(TargetFocus(
  //     keyTarget: cardsExpens,
  //     alignSkip: Alignment.topCenter,
  //     radius: 30,
  //     shape: ShapeLightFocus.RRect,
  //     contents: [
  //       TargetContent(
  //         align: ContentAlign.top,
  //         builder: (context, controller) {
  //           return Container(
  //             alignment: Alignment.center,
  //             child: Text(
  //               AppLocalizations.of(context)!.cardsTutorial,
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 40),
  //             ),
  //           );
  //         },
  //       )
  //     ]));

  // MARK: export button
  // targets.add(TargetFocus(
  //     keyTarget: exportButon,
  //     alignSkip: Alignment.bottomLeft,
  //     radius: 30,
  //     shape: ShapeLightFocus.Circle,
  //     contents: [
  //       TargetContent(
  //         align: ContentAlign.bottom,
  //         builder: (context, controller) {
  //           return Container(
  //             alignment: Alignment.center,
  //             child: Text(
  //               AppLocalizations.of(context)!.exportTutorial,
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 40),
  //             ),
  //           );
  //         },
  //       )
  //     ]));

  // MARK: Dashboard
  // targets.add(TargetFocus(
  //     keyTarget: dashboardTab,
  //     alignSkip: Alignment.topLeft,
  //     radius: 30,
  //     shape: ShapeLightFocus.Circle,
  //     contents: [
  //       TargetContent(
  //         align: ContentAlign.top,
  //         builder: (context, controller) {
  //           return Container(
  //             alignment: Alignment.center,
  //             child: Text(
  //               AppLocalizations.of(context)!.graphicsTutorial,
  //               style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 40),
  //             ),
  //           );
  //         },
  //       )
  //     ]));
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
