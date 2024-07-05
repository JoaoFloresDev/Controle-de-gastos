import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Categorycreater extends StatefulWidget {
  const Categorycreater({super.key});

  @override
  State<Categorycreater> createState() => _CategorycreaterState();
}

class _CategorycreaterState extends State<Categorycreater> {
  late TextEditingController categoriaController;
  final List<IconData> accountIcons = [
    Icons.account_balance, // Banco
    Icons.account_balance_wallet, // Carteira
    Icons.account_box, // Conta
    Icons.account_circle, // Perfil
    Icons.add_shopping_cart, // Adicionar compra
    Icons.attach_money, // Anexar dinheiro
    Icons.bar_chart, // Gráfico
    Icons.calculate, // Calcular
    Icons.calendar_today, // Calendário
    Icons.card_giftcard, // Cartão de presente
    Icons.card_membership, // Associação de cartão
    Icons.card_travel, // Cartão de viagem
    Icons.check, // Verificar
    Icons.check_box, // Caixa de seleção
    Icons.check_circle, // Círculo de verificação
    Icons.credit_card, // Cartão de crédito
    Icons.dashboard, // Painel de controle
    Icons.date_range, // Intervalo de datas
    Icons.description, // Descrição
    Icons.euro_symbol, // Símbolo do euro
    Icons.monetization_on, // Monetização
    Icons.money, // Dinheiro
    Icons.payment, // Pagamento
    Icons.pie_chart, // Gráfico de pizza
    Icons.receipt, // Recibo
    Icons.savings, // Poupança
    Icons.show_chart, // Mostrar gráfico
    Icons.wallet, // Carteira
  ];

  void adicionar() {
    print("${categoriaController.text}");
  }

  void initState() {
    super.initState();
    categoriaController = TextEditingController();
  }

  void dispose() {
    categoriaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IconData? selectedIcon;
    final TextEditingController nameController = TextEditingController();
    return Material(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(
              // to the header of the widges
              width: double.maxFinite,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Criar categoria',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Container()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  child: Column(
                children: [
                  CupertinoTextField(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.systemGrey5,
                        ),
                      ),
                    ),
                    placeholder: "Categoria",
                    controller: categoriaController,
                  ),
                  // DropdownButton está tendo problemas com hierarquia
                  //(pede sempre para adicionar o MaterialApp no main)

                  // DropdownButtonHideUnderline(
                  //   child: DropdownButton<IconData>(
                  //     hint: Text('Selecione um ícone'),
                  //     value: selectedIcon,
                  //     onChanged: (newIcon) {
                  //       setState(() {
                  //         selectedIcon = newIcon;
                  //       });
                  //     },
                  //     items: accountIcons.map((IconData icon) {
                  //       return DropdownMenuItem<IconData>(
                  //         value: icon,
                  //         child: Row(
                  //           children: [
                  //             Icon(icon),
                  //             SizedBox(width: 10),
                  //             Text(icon.toString()),
                  //           ],
                  //         ),
                  //       );
                  //     }).toList(),
                  //   ),
                  // ),
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: CupertinoButton(
                      color: CupertinoColors
                          .systemGreen.darkHighContrastElevatedColor,
                      onPressed: () {
                        adicionar();
                      },
                      child: const Text(
                        "Adicionar Categoria",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )),
            )
          ])),
    );
  }
}
