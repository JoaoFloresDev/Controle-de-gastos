import 'package:flutter/cupertino.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meus_gastos/widgets/Transactions/CampoComMascara.dart';

enum Category {
  Unknown,
  Shopping,
  Restaurant,
  GasStation,
  Home,
  ShoppingBasket,
  Hospital,
  Cigarrinho,
  Movie,
  MusicNote,
  VideoGame,
  Drink
}

class CategoryInfo {
  final Category category;
  final String name;
  final IconData icon;
  final Color color;
  CategoryInfo(this.category, this.name, this.icon, this.color);

  static Map<Category, CategoryInfo> _categories = {
    Category.Unknown: CategoryInfo(Category.Unknown, 'Sem categoria',
        Icons.question_mark_rounded, Colors.grey[800]!),
    Category.Shopping: CategoryInfo(
        Category.Shopping, 'Mercado', Icons.shopping_cart, Colors.green[900]!),
    Category.Restaurant: CategoryInfo(
        Category.Restaurant, 'Alimentação', Icons.restaurant, Colors.red[900]!),
    Category.GasStation: CategoryInfo(Category.GasStation, 'Transporte',
        Icons.local_gas_station, Colors.blue[900]!),
    Category.Home:
        CategoryInfo(Category.Home, 'Moradia', Icons.home, Colors.orange[900]!),
    Category.ShoppingBasket: CategoryInfo(Category.ShoppingBasket, 'Compras',
        Icons.shopping_basket, Colors.purple[900]!),
    Category.Hospital: CategoryInfo(
        Category.Hospital, 'Saúde', Icons.local_hospital, Colors.teal[900]!),
    Category.Cigarrinho: CategoryInfo(Category.Cigarrinho, 'Cigarrinho',
        Icons.smoking_rooms, Colors.brown[900]!),
    Category.Movie: CategoryInfo(
        Category.Movie, 'Streaming', Icons.movie, Colors.deepPurple[900]!),
    Category.MusicNote: CategoryInfo(
        Category.MusicNote, 'Gambit', Icons.music_note, Colors.pink[900]!),
    Category.VideoGame: CategoryInfo(Category.VideoGame, 'Games',
        Icons.videogame_asset, Colors.indigo[900]!),
    Category.Drink: CategoryInfo(Category.Drink, 'Bebidas',
        Icons.local_drink_outlined, Colors.cyan[900]!),
  };

  static CategoryInfo getByCategory(Category category) =>
      _categories[category] ?? _categories[Category.Unknown]!;
  static CategoryInfo getByName(String name) =>
      _categories.values.firstWhere((info) => info.name == name,
          orElse: () => _categories[Category.Unknown]!);

  static CategoryInfo getByCategoryString(String name) =>
      _categories.values.firstWhere((info) => info.category.toString() == name,
          orElse: () => _categories[Category.Unknown]!);

  static CategoryInfo getByIndex(int index) =>
      _categories[Category.values[index]] ?? _categories[Category.Unknown]!;
}
