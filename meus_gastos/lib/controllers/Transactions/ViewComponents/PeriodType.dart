import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/Constants/AppColors.dart';

// Enum para os tipos de período
enum PeriodType {
  day,
  week,
  month,
  year,
  custom,
}

// Widget do seletor de período
class PeriodSelector extends StatelessWidget {
  final PeriodType selectedPeriod;
  final Function(PeriodType) onPeriodChanged;
  final VoidCallback? onCustomPeriodTap;

  const PeriodSelector({
    Key? key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.onCustomPeriodTap,
  }) : super(key: key);

  String _getPeriodLabel(PeriodType period) {
    switch (period) {
      case PeriodType.day:
        return 'Dia';
      case PeriodType.week:
        return 'Semana';
      case PeriodType.month:
        return 'Mês';
      case PeriodType.year:
        return 'Ano';
      case PeriodType.custom:
        return 'Período';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: PeriodType.values.map((period) {
          final isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (period == PeriodType.custom && onCustomPeriodTap != null) {
                  onCustomPeriodTap!();
                } else {
                  onPeriodChanged(period);
                }
              },
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.button : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    _getPeriodLabel(period),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.label,
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Widget para mostrar o período selecionado com navegação
class PeriodNavigator extends StatelessWidget {
  final DateTime currentDate;
  final PeriodType periodType;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback? onDateTap;

  const PeriodNavigator({
    Key? key,
    required this.currentDate,
    required this.periodType,
    required this.onPrevious,
    required this.onNext,
    this.onDateTap,
  }) : super(key: key);

  String _formatPeriod() {
    switch (periodType) {
      case PeriodType.day:
        return '${currentDate.day}/${currentDate.month}/${currentDate.year}';
      case PeriodType.week:
        final weekStart = currentDate.subtract(Duration(days: currentDate.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${weekStart.day}/${weekStart.month} - ${weekEnd.day}/${weekEnd.month}';
      case PeriodType.month:
        final months = [
          'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
          'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
        ];
        return '${months[currentDate.month - 1]} ${currentDate.year}';
      case PeriodType.year:
        return '${currentDate.year}';
      case PeriodType.custom:
        return 'Período Customizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: AppColors.label),
            onPressed: onPrevious,
          ),
          GestureDetector(
            onTap: onDateTap,
            child: Text(
              _formatPeriod(),
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: AppColors.label),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// Modal para seleção de período customizado
class CustomPeriodModal extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime startDate, DateTime endDate) onConfirm;

  const CustomPeriodModal({
    Key? key,
    this.startDate,
    this.endDate,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<CustomPeriodModal> createState() => _CustomPeriodModalState();
}

class _CustomPeriodModalState extends State<CustomPeriodModal> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate ?? DateTime.now();
    _endDate = widget.endDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.button,
              surface: AppColors.background1,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Selecionar Período',
            style: TextStyle(
              color: AppColors.label,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildDateSelector(
            context,
            'Data Inicial',
            _startDate,
            () => _selectDate(context, true),
          ),
          const SizedBox(height: 16),
          _buildDateSelector(
            context,
            'Data Final',
            _endDate,
            () => _selectDate(context, false),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onConfirm(_startDate, _endDate);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.button,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Confirmar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.label.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.label,
                fontSize: 16,
              ),
            ),
            Row(
              children: [
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: const TextStyle(
                    color: AppColors.label,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.label,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}