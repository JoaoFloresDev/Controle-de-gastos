import 'package:meus_gastos/controllers/Transactions/TransactionsViewModel.dart';
import 'package:meus_gastos/controllers/ads_review/BannerAdFactory.dart';
import 'package:meus_gastos/controllers/ads_review/intersticalConstruct.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'ViewComponents/CalendarTable.dart';
import 'ViewComponents/CalendarHeader.dart';
import 'ViewComponents/CalendarTransactions.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

class CustomCalendar extends StatefulWidget {
  final VoidCallback onCalendarRefresh;
  const CustomCalendar({Key? key, required this.onCalendarRefresh}) : super(key: key);

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<CardModel> _transactionsForSelectedDay = [];
  Map<DateTime, double> _dailyExpenses = {};
  final InterstitialAdManager _adManager = InterstitialAdManager();

  @override
  void initState() {
    super.initState();
    _adManager.loadAd();
  }

  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }

  Map<DateTime, double> _calculateDailyExpenses(List<CardModel> allTransactions) {
    final Map<DateTime, double> expenses = {};
    
    for (var transaction in allTransactions) {
      final day = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      expenses[day] = (expenses[day] ?? 0) + transaction.amount;
    }
    
    return expenses;
  }

  List<CardModel> _getTransactionsForDay(List<CardModel> allTransactions, DateTime day) {
    return allTransactions.where((card) =>
      card.date.year == day.year &&
      card.date.month == day.month &&
      card.date.day == day.day
    ).toList();
  }

  void refreshCalendar() {
    setState(() {
      // Força recálculo na próxima build
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Busca todas as transações do ViewModel
    final transactionsViewModel = context.watch<TransactionsViewModel>();
    final allTransactions = transactionsViewModel.cardList.where((card)=>card.amount > 0).toList();

    // 2. Calcula gastos diários baseado em TODAS as transações
    _dailyExpenses = _calculateDailyExpenses(allTransactions);

    // 3. Filtra transações para o dia selecionado/focado
    _transactionsForSelectedDay = _getTransactionsForDay(
      allTransactions,
      _selectedDay ?? _focusedDay,
    );

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
        backgroundColor: AppColors.background1,
      ),
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
                  child: Column(
                    children: [
                      CalendarTable(
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        dailyExpenses: _dailyExpenses,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                      CalendarHeader(
                        selectedDay: _selectedDay,
                        focusedDay: _focusedDay,
                        dailyExpenses: _dailyExpenses,
                      ),
                      TransactionList(
                        transactions: _transactionsForSelectedDay,
                        // categories: context.read<>(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}