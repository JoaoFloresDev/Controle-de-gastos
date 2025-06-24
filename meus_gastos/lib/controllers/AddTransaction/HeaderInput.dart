import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionInput extends StatelessWidget {
  final TextEditingController valueController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<int> values = [5, 10, 20, 50, 100, 200];

  TransactionInput({super.key});

  String getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('HH:mm, dd MMM', 'pt_BR').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nova Transação',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                getFormattedDate(),
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Valor e descrição
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botões positivos
          Wrap(
            spacing: 8,
            children: values
                .map((v) => ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: Text('+$v'),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),

          // Botões negativos
          Wrap(
            spacing: 8,
            children: values
                .map((v) => ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('-$v'),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
