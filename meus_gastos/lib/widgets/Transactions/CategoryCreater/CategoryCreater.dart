import 'package:fl_chart/fl_chart.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Categorycreater extends StatefulWidget {
  Categorycreater({super.key});

  @override
  State<Categorycreater> createState() => _CategorycreaterState();
}

class _CategorycreaterState extends State<Categorycreater> {
  late TextEditingController categoriaController;
  late Color _currentColor = Colors.black;
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

  void adicionar() async {
    print("${categoriaController.text}");
    CategoryModel category = CategoryModel(
        id: Uuid().v4(),
        color:
            _currentColor, // aqui tem que ser uma cor aleatória ou adicionar um selecionador de cor na tela
        icon: accountIcons[
            selectedIndex], // aqui precisa ser o icone que o usuário selecionou
        name: categoriaController.text,
        frequency: 0);

    await CategoryService().addCategory(category);
  }

  int selectedIndex = 0;
  void initState() {
    super.initState();
    categoriaController = TextEditingController();
  }

  void dispose() {
    categoriaController.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Widget buildColorPicker() {
    return ColorPicker(
      pickerColor: _currentColor,
      onColorChanged: (Color color) {
        setState(() {
          _currentColor = color;
        });
      },
      showLabel: false,
      pickerAreaHeightPercent: 0.8,
      displayThumbColor: false,
      enableAlpha: false,
      paletteType:
          PaletteType.hsv, // You can change this to another type if needed
    );
  }

  void _pickColor(BuildContext context) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              color: Colors.black54,
              child: GestureDetector(
                onTap: () {},
                child: CupertinoAlertDialog(
                  title: Text(
                    'Escolha a cor',
                    style: TextStyle(fontSize: 20),
                  ),
                  content: Container(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        buildColorPicker(),
                        TextButton(
                          child: Text(
                            'Selecionar',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 93, 168),
                                fontSize: 20),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    IconData? selectedIcon;
    final TextEditingController nameController = TextEditingController();
    return Material(
      child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey[900],
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
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
                onTap: _hideKeyboard,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                      child: Column(
                    children: [
                      AddCategoryHorizontalCircleList(
                        onItemSelected: (index) {
                          selectedIndex = index;
                        },
                      ),
                      CupertinoTextField(
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey5,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: CupertinoColors.systemGrey5,
                            ),
                          ),
                        ),
                        placeholder: "Categoria",
                        controller: categoriaController,
                      ),
                      const SizedBox(height: 24),
                      Row(children: [
                        Text(
                          "Escolha a cor: ",
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(width: 15),
                        GestureDetector(
                          onTap: () => _pickColor(context),
                          child: Container(
                            decoration: BoxDecoration(
                                color: _currentColor,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(40)),
                            height: 40,
                            width: 40,
                          ),
                        )
                      ]),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: CupertinoButton(
                          color: CupertinoColors
                              .systemGreen.darkHighContrastElevatedColor,
                          onPressed: () {
                            if (categoriaController.text.isNotEmpty) {
                              adicionar();
                            }
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Adicionar Categoria",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  )),
                )),
          ])),
    );
  }
}

class AddCategoryHorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;

  const AddCategoryHorizontalCircleList({
    Key? key,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _AddCategoryHorizontalCircleListState createState() =>
      _AddCategoryHorizontalCircleListState();
}

class _AddCategoryHorizontalCircleListState
    extends State<AddCategoryHorizontalCircleList> {
  int selectedIndex = 0;
  int lastSelectedIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60, // Ajuste a altura para acomodar o círculo e o texto
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: accountIcons.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                lastSelectedIndex = selectedIndex;
                selectedIndex = index;
              });
              widget.onItemSelected(index);
            },
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Para evitar preencher todo o espaço vertical
              children: [
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(accountIcons[index]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
