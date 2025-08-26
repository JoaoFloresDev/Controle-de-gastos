import 'package:meus_gastos/controllers/ads_review/constructReview.dart';
import 'package:meus_gastos/controllers/ads_review/intersticalConstruct.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/controllers/gastos_fixos/ListCardFixeds.dart';
import 'package:meus_gastos/controllers/gastos_fixos/UI/criar_gastosFixos.dart';
import 'package:meus_gastos/services/CardService.dart';
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
    _initializeCalendarData();
    _adManager.loadAd();
  }

  @override
  void dispose() {
    _adManager.dispose(); 
    super.dispose();
  }

  Future<void> _checkAndRequestReview() async {
    ReviewService.checkAndRequestReview(context);
    final prefs = await SharedPreferences.getInstance();
    int sessionCount = prefs.getInt('session_count') ?? 0;
    if ((sessionCount == 6) || (sessionCount % 5 == 0 && sessionCount > 10)) {
      _adManager.showVideoAd(context);
    }
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

  @override
  Widget build(BuildContext context) {
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
            const BannerAdconstruct(),
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
                    onRefresh: () {
                      _loadTransactionsForDay(_selectedDay ?? DateTime.now());
                    },
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
