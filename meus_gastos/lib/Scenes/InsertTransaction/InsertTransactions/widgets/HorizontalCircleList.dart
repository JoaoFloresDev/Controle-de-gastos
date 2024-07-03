import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter/material.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/models/CategoryModel.dart';
import 'package:meus_gastos/Scenes/InsertTransaction/InsertTransactions/widgets/CategoryCreater.dart';
import 'CampoComMascara.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum Category {
  Unknown, // sem categoria
  Shopping, // mercado
  Restaurant, // alimentação
  GasStation, // carro
  Home, // moradia
  ShoppingBasket, // compras
  Hospital, // Saúde
  Cigarrinho, // Cigarrinho
  Movie, // idas ao shopping
  MusicNote, // strimings
  VideoGame, // aplicativos
  Drink, // roles
}

String getCategoryNameByEnum(Category category) {
  switch (category) {
    case Category.Unknown:
      return 'Sem categoria';
    case Category.Shopping:
      return 'Mercado';
    case Category.Restaurant:
      return 'Alimentação';
    case Category.GasStation:
      return 'Transporte';
    case Category.Home:
      return 'Moradia';
    case Category.ShoppingBasket:
      return 'Compras';
    case Category.Hospital:
      return 'Saúde';
    case Category.Cigarrinho:
      return 'Cigarrinho';
    case Category.Movie:
      return 'Streaming';
    case Category.MusicNote:
      return 'Gambit';
    case Category.VideoGame:
      return 'Games';
    case Category.Drink:
      return 'Bebidas';
    default:
      return '';
  }
}

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;

  const HorizontalCircleList({
    Key? key,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  _HorizontalCircleListState createState() => _HorizontalCircleListState();
}

class _HorizontalCircleListState extends State<HorizontalCircleList> {
  int selectedIndex = 0;
  int lastSelectedIndex = 0;
  final List<CategoryModel> lista_categorias = [
    CategoryModel(id: 0, icon: Icons.question_mark_rounded, name: "Sem categoria"),
    CategoryModel(id: 1, icon: Icons.shopping_cart, name: "Mercado"),
    CategoryModel(id: 2, icon: Icons.restaurant, name: "Alimentação"),
    CategoryModel(id: 3, icon: Icons.local_gas_station, name: "Carro"),
    CategoryModel(id: 4, icon: Icons.home, name: "Moradia"),
    CategoryModel(id: 5, icon: Icons.shopping_basket, name: "Compras"),
    CategoryModel(id: 6, icon: Icons.local_hospital, name: "Saúde"),
    CategoryModel(id: 7, icon: Icons.smoking_rooms, name: "Cigarrinho"),
    CategoryModel(id: 8, icon: Icons.movie, name: "Idas ao Shopping"),
    CategoryModel(id: 9, icon: Icons.music_note, name: "Streamings"),
    CategoryModel(id: 10, icon: Icons.videogame_asset, name: "Aplicativos"),
    CategoryModel(id: 11, icon: Icons.local_bar, name: "Rolês"),
  ];
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Ajuste a altura para acomodar o círculo e o texto
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lista_categorias.length + 1,
        itemBuilder: (context, index) {
          if (index == Category.values.length) {
            // Adiciona o botão na última posição
            return Column(
                mainAxisSize: MainAxisSize
                    .min, // Para evitar preencher todo o espaço vertical
                children: [RoundButton()]);
          } else {
            final category = lista_categorias[index];
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
                    width: 60,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: selectedIndex == index
                          ? Colors.green.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      category.icon,
                    ),
                  ),

                  SizedBox(height: 4), // Espaço entre o ícone e o texto
                  Text(
                    "${category.name}", // Use a função correta para obter o nome da categoria
                    style: TextStyle(
                      fontSize: 9, // Ajuste conforme necessário
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

String getCategoryNameByIndex(int index) {
  switch (Category.values[index]) {
    case Category.Shopping:
      return 'Shopping';
    case Category.Restaurant:
      return 'Restaurant';
    case Category.GasStation:
      return 'GasStation';
    case Category.Home:
      return 'Home';
    case Category.ShoppingBasket:
      return 'ShoppingBasket';
    case Category.Hospital:
      return 'Hospital';
    case Category.Cigarrinho:
      return 'Volleyball';
    case Category.Movie:
      return 'Movie';
    case Category.MusicNote:
      return 'MusicNote';
    case Category.VideoGame:
      return 'VideoGame';
    case Category.Drink:
      return 'Drink';
    default:
      return 'Unknown';
  }
}

Category getCategoryByName(String name) {
  switch (name) {
    case 'Shopping':
      return Category.Shopping;
    case 'Restaurant':
      return Category.Restaurant;
    case 'GasStation':
      return Category.GasStation;
    case 'Home':
      return Category.Home;
    case 'ShoppingBasket':
      return Category.ShoppingBasket;
    case 'Hospital':
      return Category.Hospital;
    case 'Volleyball':
      return Category.Cigarrinho;
    case 'Movie':
      return Category.Movie;
    case 'MusicNote':
      return Category.MusicNote;
    case 'VideoGame':
      return Category.VideoGame;
    case 'Drink':
      return Category.Drink;
    default:
      return Category.Unknown;
  }
}

IconData getIconByCategory(Category category) {
  switch (category) {
    case Category.Shopping:
      return Icons.shopping_cart;
    case Category.Restaurant:
      return Icons.restaurant;
    case Category.GasStation:
      return Icons.local_gas_station;
    case Category.Home:
      return Icons.home;
    case Category.ShoppingBasket:
      return Icons.shopping_basket;
    case Category.Hospital:
      return Icons.local_hospital;
    case Category.Cigarrinho:
      return Icons.smoking_rooms;
    case Category.Movie:
      return Icons.movie;
    case Category.MusicNote:
      return Icons.music_note;
    case Category.VideoGame:
      return Icons.videogame_asset;
    case Category.Drink:
      return Icons.local_drink_outlined;
    default:
      return Icons.question_mark_rounded;
  }
}

class RoundButton extends StatelessWidget {
  void ShowCategoryModel(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: MediaQuery.of(context).size.height / 1.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Categorycreater(),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: InkWell(
            onTap: () {
              ShowCategoryModel(context);
            },
            customBorder: const CircleBorder(),
            child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Para evitar preencher todo o espaço vertical
                children: [
                  Ink(
                    width: 60,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add, // Ícone do botão
                        size: 20.0, // Ajustar o tamanho do ícone se necessário
                      ),
                    ),
                  ),
                ]),
          ),
        ),
        SizedBox(height: 4), // Espaço entre o botão e o texto
        Text(
          "Adicionar",
          style: TextStyle(
            fontSize: 9, // Ajuste conforme necessário
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
