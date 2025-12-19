import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:intl/intl.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';
import 'package:meus_gastos/models/CategoryModel.dart';

class TranslateService {
  static String getCurrencySymbol(BuildContext context) {
    Locale locale = Localizations.localeOf(context);

    // Cria um formatter para moeda com base no locale
    NumberFormat currencyFormat =
        NumberFormat.simpleCurrency(locale: locale.toString());

    // Retorna o símbolo da moeda (R$, US$, etc.)
    return currencyFormat.currencySymbol;
  }

  static String formatCurrency(double amount, BuildContext context) {
    Locale locale = Localizations.localeOf(context);

    // Formata o valor de acordo com a região e adiciona o símbolo da moeda
    NumberFormat currencyFormat =
        NumberFormat.simpleCurrency(locale: locale.toString());

    return currencyFormat.format(amount);
  }

  String formatDate(DateTime date, BuildContext context) {
    Locale locale = Localizations.localeOf(context);

    // Cria um formatter de data com base na localidade
    DateFormat dateFormat = DateFormat.yMd(locale.toString());

    // Formata a data
    return dateFormat.format(date);
  }

  static String getTranslatedCategoryUsingModel(
      BuildContext context, CategoryModel category) {
    switch (category.id) {
      case 'Unknown':
        return AppLocalizations.of(context)!.unknown;
      case 'Shopping':
        return AppLocalizations.of(context)!.shopping;
      case 'Restaurant':
        return AppLocalizations.of(context)!.restaurant;
      case 'GasStation':
        return AppLocalizations.of(context)!.gasStation;
      case 'Home':
        return AppLocalizations.of(context)!.home;
      case 'ShoppingBasket':
        return AppLocalizations.of(context)!.shoppingBasket;
      case 'Hospital':
        return AppLocalizations.of(context)!.hospital;
      case 'Transport':
        return AppLocalizations.of(context)!.transport;
      case 'Education':
        return AppLocalizations.of(context)!.education;
      case 'Movie':
        return AppLocalizations.of(context)!.movie;
      case 'VideoGame':
        return AppLocalizations.of(context)!.videoGame;
      case 'fun':
        return AppLocalizations.of(context)!.fun;
      case 'Water':
        return AppLocalizations.of(context)!.water;
      case 'Light':
        return AppLocalizations.of(context)!.light;
      case 'Wifi':
        return AppLocalizations.of(context)!.wifi;
      case 'Phone':
        return AppLocalizations.of(context)!.phone;
      case 'CreditCard':
        return AppLocalizations.of(context)!.creditCard;
      case 'AddCategory':
        return AppLocalizations.of(context)!.addCategory;
      default:
        return category.name; // Retorna o valor original se não houver tradução
    }
  }

  static String getTranslatedCategoryName(BuildContext context, String legend) {
    switch (legend) {
      case 'Unknown':
        return AppLocalizations.of(context)!.unknown;
      case 'Shopping':
        return AppLocalizations.of(context)!.shopping;
      case 'Restaurant':
        return AppLocalizations.of(context)!.restaurant;
      case 'GasStation':
        return AppLocalizations.of(context)!.gasStation;
      case 'Home':
        return AppLocalizations.of(context)!.home;
      case 'ShoppingBasket':
        return AppLocalizations.of(context)!.shoppingBasket;
      case 'Hospital':
        return AppLocalizations.of(context)!.hospital;
      case 'Movie':
        return AppLocalizations.of(context)!.movie;
      case 'VideoGame':
        return AppLocalizations.of(context)!.videoGame;
      case 'fun':
        return AppLocalizations.of(context)!.fun;
      case 'Water':
        return AppLocalizations.of(context)!.water;
      case 'Light':
        return AppLocalizations.of(context)!.light;
      case 'Wifi':
        return AppLocalizations.of(context)!.wifi;
      case 'Phone':
        return AppLocalizations.of(context)!.phone;
      case 'Credit Card':
        return AppLocalizations.of(context)!.creditCard;
      case 'AddCategory':
        return AppLocalizations.of(context)!.addCategory;
      default:
        return legend; // Retorna o valor original se não houver tradução
    }
  }
}
