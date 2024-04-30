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

  CategoryInfo(this.category, this.name, this.icon);

  static Map<Category, CategoryInfo> _categories = {
    Category.Unknown: CategoryInfo(
        Category.Unknown, 'Sem categoria', Icons.question_mark_rounded),
    Category.Shopping:
        CategoryInfo(Category.Shopping, 'Mercado', Icons.shopping_cart),
    Category.Restaurant:
        CategoryInfo(Category.Restaurant, 'Alimentação', Icons.restaurant),
    Category.GasStation: CategoryInfo(
        Category.GasStation, 'Transporte', Icons.local_gas_station),
    Category.Home: CategoryInfo(Category.Home, 'Moradia', Icons.home),
    Category.ShoppingBasket:
        CategoryInfo(Category.ShoppingBasket, 'Compras', Icons.shopping_basket),
    Category.Hospital:
        CategoryInfo(Category.Hospital, 'Saúde', Icons.local_hospital),
    Category.Cigarrinho:
        CategoryInfo(Category.Cigarrinho, 'Cigarrinho', Icons.smoking_rooms),
    Category.Movie: CategoryInfo(Category.Movie, 'Streaming', Icons.movie),
    Category.MusicNote:
        CategoryInfo(Category.MusicNote, 'Gambit', Icons.music_note),
    Category.VideoGame:
        CategoryInfo(Category.VideoGame, 'Games', Icons.videogame_asset),
    Category.Drink:
        CategoryInfo(Category.Drink, 'Bebidas', Icons.local_drink_outlined),
  };

  static CategoryInfo getByCategory(Category category) =>
      _categories[category] ?? _categories[Category.Unknown]!;
  static CategoryInfo getByName(String name) =>
      _categories.values.firstWhere((info) => info.name == name,
          orElse: () => _categories[Category.Unknown]!);
  static CategoryInfo getByIndex(int index) =>
      _categories[Category.values[index]] ?? _categories[Category.Unknown]!;
}
