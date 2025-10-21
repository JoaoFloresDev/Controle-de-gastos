import 'package:meus_gastos/designSystem/ImplDS.dart';

class CardEvents extends ChangeNotifier {
  void notifyCardAdded() {
    notifyListeners();
  }
}

