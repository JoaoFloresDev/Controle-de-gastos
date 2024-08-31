import 'package:meus_gastos/designSystem/ImplDS.dart';

class SizeOf {
  final BuildContext context;

  SizeOf(this.context);

  Modal get modal => Modal(context);
}

class Modal {
  final BuildContext context;

  Modal(this.context);

  double halfModal() {
    return MediaQuery.of(context).size.height / 2;
  }

  double mediumModal() {
    return MediaQuery.of(context).size.height / 1.2;
  }
}
