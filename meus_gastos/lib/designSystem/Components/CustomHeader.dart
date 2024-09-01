import 'package:meus_gastos/designSystem/ImplDS.dart';

class CustomHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onCancelPressed;
  final VoidCallback? onDeletePressed;
  final bool
      showDeleteButton; // Adiciona um parâmetro para controlar a exibição do botão de deletar

  CustomHeader({
    required this.title,
    this.onCancelPressed,
    this.onDeletePressed,
    this.showDeleteButton =
        false, // Define o botão de deletar como visível por padrão
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Botão de Cancelar
          _buildCancelButton(context),
          // Título
          _buildTitle(),
          // Botão de Deletar (opcional)
          _buildDeleteButton(context),
        ],
      ),
    );
  }

  // MARK: - Cancel Button
  Widget _buildCancelButton(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.close, color: AppColors.label),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  // MARK: - Title
  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.label,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // MARK: - Delete Button
  Widget _buildDeleteButton(BuildContext context) {
    return IconButton(
      onPressed: onDeletePressed,
      icon: Icon(
        Icons.delete,
        color: showDeleteButton ? AppColors.deletionButton : Colors.transparent,
      ),
    );
  }
}
