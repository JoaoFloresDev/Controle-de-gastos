import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/ads_review/BannerAdFactory.dart';
import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/intersticalConstruct.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'ViewComponents/CalendarTable.dart';
import 'ViewComponents/CalendarHeader.dart';
import 'ViewComponents/CalendarTransactions.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

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
    // _initializeCalendarData();
    _adManager.loadAd();
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  Future<void> _initializeCalendarData() async {
    await _calculateDailyExpenses();
    await _loadTransactionsForDay(_focusedDay);
  }

  Future<void> _calculateDailyExpenses() async {
    
    final Map<DateTime, double> expenses = {};

    for (var transaction in _transactions) {
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
    final transactionsForDay = _transactions
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

  @override
  Widget build(BuildContext context) {
    TransactionsViewModel transactionsViewModel =
        context.watch<TransactionsViewModel>();
    _transactions = transactionsViewModel.cardList;
    _loadTransactionsForDay(_focusedDay);
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: CupertinoNavigationBar(
          middle: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Text(
              AppLocalizations.of(context)!.calendar,
              style: const TextStyle(color: AppColors.label, fontSize: 20),
            ),
          ),
          backgroundColor: AppColors.background1),
      body: SafeArea(
        child: Column(
          children: [
            BannerAdFactory().build(),
            Expanded(
              child: SingleChildScrollView(
                  child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(children: [
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
                  TransactionList(
                    transactions: _transactions,
                  ),
                ]),
              )),
            )
          ],
        ),
      ),
    );
  }
}
