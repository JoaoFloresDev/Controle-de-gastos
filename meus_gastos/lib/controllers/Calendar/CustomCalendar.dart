import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'dart:io';
import 'package:meus_gastos/controllers/Purchase/ProModalAndroid.dart';
import 'package:meus_gastos/controllers/ads_review/intersticalConstruct.dart';
import 'package:meus_gastos/gastos_fixos/CardDetails/DetailScreenMainScrean.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:meus_gastos/controllers/Purchase/ProModal.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/gastos_fixos/ListCard.dart';
import 'package:meus_gastos/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesModel.dart';
import 'package:meus_gastos/gastos_fixos/fixedExpensesService.dart';
import '../../../models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart' as service;
import 'package:meus_gastos/controllers/CardDetails/DetailScreen.dart';
import 'package:meus_gastos/controllers/CategoryCreater/CategoryCreater.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/bannerAdconstruct.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'package:meus_gastos/controllers/Transactions/InsertTransactions/ViewComponents/ListCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/services/CardService.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';
import 'ViewComponents/CalendarTable.dart';
import 'ViewComponents/CalendarHeader.dart';
import 'ViewComponents/CalendarTransactions.dart';

class CustomCalendar extends StatefulWidget {
  final VoidCallback onCalendarRefresh;

  const CustomCalendar({Key? key, required this.onCalendarRefresh})
      : super(key: key);

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CardModel> _transactions = [];
  Map<DateTime, double> _dailyExpenses = {};
  
  final InterstitialAdManager _adManager = InterstitialAdManager();


  @override
  void initState() {
    super.initState();
    _checkUserProStatus();
    _initializeCalendarData();
    _adManager.loadAd();
  }

  @override
  void dispose() {
    _adManager.dispose(); // Libera os recursos do anúncio ao sair da tela.
    super.dispose();
  }

  Future<void> _checkAndRequestReview() async {
    ReviewService.checkAndRequestReview(context);
    final prefs = await SharedPreferences.getInstance();
    int sessionCount = prefs.getInt('session_count') ?? 0;
    if ((sessionCount == 6) || (sessionCount % 5 == 0 && sessionCount > 10)){
      if (!_isPro)
      _adManager.showAd(context);
    }
  }

  Future<void> _checkUserProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isYearlyPro = prefs.getBool('yearly.pro') ?? false;
    bool isMonthlyPro = prefs.getBool('monthly.pro') ?? false;
    setState(() {
      _isPro = isYearlyPro || isMonthlyPro;
    });
  }

  Future<void> _initializeCalendarData() async {
    await _calculateDailyExpenses();
    await _loadTransactionsForDay(_focusedDay);
    _checkAndRequestReview();
  }

  Future<void> _calculateDailyExpenses() async {
    final allTransactions = await CardService.retrieveCards();
    final Map<DateTime, double> expenses = {};

    for (var transaction in allTransactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      expenses[day] = (expenses[day] ?? 0) + transaction.amount;
    }

    setState(() {
      _dailyExpenses = expenses;
    });
  }

  Future<void> _loadTransactionsForDay(DateTime day) async {
    final allTransactions = await CardService.retrieveCards();
    final transactionsForDay = allTransactions
        .where((card) =>
            card.date.year == day.year &&
            card.date.month == day.month &&
            card.date.day == day.day)
        .toList();

    setState(() {
      _transactions = transactionsForDay;
    });
  }

  void refreshCalendar() {
    _initializeCalendarData();
  }

  bool _isPro = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: CupertinoNavigationBar(
          middle: Text(
            AppLocalizations.of(context)!.calendar,
            style: const TextStyle(color: AppColors.label, fontSize: 16),
          ),
          backgroundColor: AppColors.background1),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isPro && !Platform.isMacOS)
              Container(
                height: 60,
                width: double.infinity, // Largura total da tela
                alignment: Alignment.center, // Centraliza no eixo X
                child: BannerAdconstruct(),
              ),
            CalendarTable(
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              dailyExpenses: _dailyExpenses,
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _loadTransactionsForDay(selectedDay);
              },
            ),
            CalendarHeader(
              selectedDay: _selectedDay,
              focusedDay: _focusedDay,
              dailyExpenses: _dailyExpenses,
            ),
            Expanded(
              child: TransactionList(
                transactions: _transactions,
                onRefresh: () {
                  _loadTransactionsForDay(_selectedDay ?? DateTime.now());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
