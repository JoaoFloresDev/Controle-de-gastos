// import 'package:meus_gastos/controllers/CategoryCreater/AddCategoryHorizontalCircleList.dart';
import 'package:meus_gastos/controllers/Goals/GoalsService.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
// import 'package:meus_gastos/controllers/CategoryCreater/AddCategoryHorizontalCircleList.dart';
import 'package:meus_gastos/controllers/Goals/GoalsService.dart';
import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
import 'package:meus_gastos/services/TranslateService.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/services/CategoryService.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/controllers/CategoryCreater/AddCategoryHorizontalCircleList.dart';

class Categorycreater extends StatefulWidget {
  final VoidCallback onCategoryAdded;

  const Categorycreater({super.key, required this.onCategoryAdded});

  @override
  State<Categorycreater> createState() => _CategorycreaterState();
}

class _CategorycreaterState extends State<Categorycreater> {
  late TextEditingController categoriaController;
  late Color _currentColor =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  late Future<List<CategoryModel>> _futureCategories = Future.value([]);

  int selectedIndex = 0;

  // MARK: - Lifecycle Methods
  @override
  void initState() {
    super.initState();
    categoriaController = TextEditingController();
    _futureCategories = CategoryService().getAllCategoriesAvaliable();
  }

  @override
  void dispose() {
    categoriaController.dispose();
    super.dispose();
  }

  // MARK: - Helper Methods
  void _hideKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void _pickColor(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            color: Colors.transparent, // Fundo transparente ao redor do diálogo
            child: GestureDetector(
              onTap: () {},
              child: CupertinoAlertDialog(
                content: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.chooseColor,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ColorPicker(
                        pickerColor: _currentColor,
                        onColorChanged: (Color color) {
                          setState(() {
                            _currentColor = color;
                          });
                        },
                        showLabel: false,
                        pickerAreaHeightPercent: 0.6,
                        displayThumbColor: false,
                        enableAlpha: false,
                        paletteType: PaletteType.hsv,
                        pickerAreaBorderRadius:
                            const BorderRadius.all(Radius.circular(0)),
                      ),
                      SizedBox(
                        width: 160,
                        height: 40,
                        child: CupertinoButton(
                          color: AppColors.button, // Cor de fundo azul
                          borderRadius: BorderRadius.circular(
                              8.0), // Cantos ligeiramente arredondados
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0), // Tamanho do botão
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            AppLocalizations.of(context)!.select,
                            style: const TextStyle(
                              color: Colors.white, // Cor do texto branco
                              fontSize: 16.0, // Tamanho do texto
                              fontWeight: FontWeight.bold, // Texto em negrito
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildColorPicker() {
    return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(8),
        child: ColorPicker(
            pickerColor: _currentColor,
            onColorChanged: (Color color) {
              setState(() {
                _currentColor = color;
              });
            },
            showLabel: false,
            pickerAreaHeightPercent: 0.6,
            displayThumbColor: false,
            enableAlpha: false,
            paletteType: PaletteType.hsv,
            pickerAreaBorderRadius:
                const BorderRadius.all(Radius.circular(20))));
  }

  // MARK: - Add Category
  void adicionar() async {
    int frequency = 2;
    CategoryModel? categoryHighFrequency =
        await CategoryService.getCategoryWithHighestFrequency();
    if (categoryHighFrequency != null && categoryHighFrequency.id.isNotEmpty) {
      frequency = categoryHighFrequency.frequency + 1;
    }
    CategoryModel category = CategoryModel(
        id: const Uuid().v4(),
        color: _currentColor,
        icon: accountIcons[selectedIndex],
        name: categoriaController.text,
        frequency: frequency);

    await CategoryService().addCategory(category);
    widget.onCategoryAdded();
    setState(() {
      _futureCategories = CategoryService().getAllCategoriesAvaliable();
    });
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(0),
        decoration: const BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomHeader(
              title: AppLocalizations.of(context)!.createCategory,
              onCancelPressed: () {
                Navigator.pop(context);
              },
            ),
            GestureDetector(
              onTap: _hideKeyboard,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      AddCategoryHorizontalCircleList(
                        onItemSelected: (index) {
                          setState(() {
                            selectedIndex = index;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        style: const TextStyle(
                          color: Color.fromARGB(255, 252, 252, 254),
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ),
                        placeholder: AppLocalizations.of(context)!.category,
                        placeholderStyle: const TextStyle(
                            color: Color.fromARGB(144, 255, 255, 255)),
                        controller: categoriaController,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(15),
                        ],
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          Text(
                            "${AppLocalizations.of(context)!.chooseColor} ",
                            style: const TextStyle(
                                color: AppColors.label, fontSize: 20),
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => _pickColor(context),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _currentColor,
                                border: Border.all(
                                  color: AppColors.button,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              height: 30,
                              width: 30,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: SizedBox(
    width: double.infinity,
    child: CupertinoButton(
      color: AppColors.button,
      onPressed: () {
        if (categoriaController.text.isNotEmpty) {
          adicionar();
          FocusScope.of(context).unfocus();
          // Navigator.pop(context);
        }
      },
      child: Text(
        AppLocalizations.of(context)!.addCategory,
        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.label),
      ),
    ),
  ),
),
const SizedBox(height: 40),
Stack(
  children: [
    SizedBox(
      height: MediaQuery.of(context).size.height - 550,
      child: FutureBuilder<List<CategoryModel>>(
        future: _futureCategories,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error", style: TextStyle(color: Colors.white)));
          } else if (snapshot.hasData) {
            final categories = snapshot.data!;
            if (categories.isEmpty) {
              return Center(child: Text("No categories found", style: TextStyle(color: Colors.white)));
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: categories.length - 1,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  margin: EdgeInsets.only(left: 16, right: 16, top: index == 0 ? 30 : 8, bottom: index == categories.length - 2 ? 40 : 8),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(category.icon, color: category.color, size: 30),
                    title: Text(TranslateService.getTranslatedCategoryUsingModel(context, category), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        CategoryService().deleteCategory(category.id);
                        setState(() {
                          widget.onCategoryAdded();
                          _futureCategories = CategoryService().getAllCategories();
                        });
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    ),
    Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background1,
              AppColors.background1.withOpacity(0),
            ],
          ),
        ),
      ),
    ),
    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppColors.background1,
              AppColors.background1.withOpacity(0),
            ],
          ),
        ),
      ),
    ),
  ],
)


                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// class AddCategoryHorizontalCircleList extends StatefulWidget {
//   final Function(int) onItemSelected;

//   const AddCategoryHorizontalCircleList({
//     super.key,
//     required this.onItemSelected,
//   });

//   @override
//   _AddCategoryHorizontalCircleListState createState() =>
//       _AddCategoryHorizontalCircleListState();
// }

// class _AddCategoryHorizontalCircleListState
//     extends State<AddCategoryHorizontalCircleList> {
//   int selectedIndex = 0;

//   final List<IconData> accountIcons = [
//     // Alimentação
//     Icons.restaurant, // Restaurante
//     Icons.fastfood, // Comida rápida
//     Icons.local_pizza, // Pizza ou delivery
//     Icons.coffee, // Cafeteria ou bebidas

//     // Transporte
//     Icons.directions_car, // Carro
//     Icons.local_taxi, // Táxi ou ride-share
//     Icons.train, // Trem ou transporte público
//     Icons.directions_bus, // Ônibus
//     Icons.airplanemode_active, // Viagem de avião
//     Icons.electric_bike, // Bicicleta elétrica ou transporte alternativo

//     // Compras
//     Icons.shopping_cart, // Compras gerais
//     Icons.shopping_bag, // Sacola de compras
//     Icons.card_giftcard, // Presentes
//     Icons.local_mall, // Shopping ou lojas

//     // Entretenimento e lazer
//     Icons.movie, // Cinema ou filmes
//     Icons.sports_esports, // Jogos eletrônicos
//     Icons.music_note, // Música
//     Icons.theater_comedy, // Teatro ou eventos
//     Icons.local_bar, // Bar ou festas

//     // Contas e serviços
//     Icons.lightbulb, // Eletricidade
//     Icons.water_drop, // Água
//     Icons.wifi, // Internet
//     Icons.phone, // Telefone
//     Icons.home, // Aluguel ou hipoteca

//     // Saúde e bem-estar
//     Icons.health_and_safety, // Saúde geral
//     Icons.medical_services, // Serviços médicos
//     Icons.fitness_center, // Academia
//     Icons.spa, // Bem-estar ou estética

//     // Educação
//     Icons.school, // Educação ou cursos
//     Icons.menu_book, // Livros ou materiais de estudo
//     Icons.laptop, // Cursos online ou tecnologia

//     // Família e cuidado pessoal
//     Icons.child_friendly, // Crianças
//     Icons.pets, // Animais de estimação
//     Icons.cleaning_services, // Limpeza
//     Icons.baby_changing_station, // Produtos para bebês

//     // Economia e investimentos
//     Icons.attach_money, // Dinheiro
//     Icons.savings, // Poupança
//     Icons.trending_up, // Investimentos
//     Icons.money_off, // Gastos inesperados

//     // Viagens e turismo
//     Icons.hotel, // Hospedagem
//     Icons.beach_access, // Praia ou férias
//     Icons.map, // Turismo

//     // Outras categorias
//     Icons.construction, // Manutenção ou reparos
//     Icons.work, // Trabalho
//     Icons.volunteer_activism, // Doações
//     Icons.local_florist, // Flores ou jardinagem
//     Icons.cake, // Festas ou celebrações
//     Icons.devices, // Eletrônicos
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 60,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: accountIcons.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedIndex = index;
//               });
//               widget.onItemSelected(index);
//             },
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 50,
//                   height: 50,
//                   margin: const EdgeInsets.symmetric(horizontal: 8),
//                   decoration: BoxDecoration(
//                     color: selectedIndex == index
//                         ? AppColors.buttonSelected
//                         : AppColors.buttonDeselected,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(accountIcons[index]),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
