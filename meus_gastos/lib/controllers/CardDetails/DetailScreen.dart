import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CardModel.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'EditionHeaderCard.dart';
import 'package:meus_gastos/l10n/app_localizations.dart';

// await Constructreview.checkAndRequestReview();
class DetailScreen extends StatefulWidget {
  final CardModel card;
  final VoidCallback onAddClicked;
  final Function(CardModel) onDelete;
  final List<CategoryModel> categories;
  final Function(CardModel, CardModel) onAddCardPressed;
  const DetailScreen(
      {super.key,
      required this.card,
      required this.onAddClicked,
      required this.onDelete,
      required this.categories,
      required this.onAddCardPressed});

  @override
  _DetailScreen createState() => _DetailScreen();
}

class _DetailScreen extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    // widget.categoryVM.avaliebleCetegories.removeLast();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background1,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            CustomHeader(
              title: AppLocalizations.of(context)!.transactionDetails,
              onCancelPressed: () {
                // FocusScope.of(context).unfocus();
                Navigator.of(context).pop();
              },
              onDeletePressed: () {
                widget.onDelete(widget.card);
                // SaveExpensOnCloud().deleteDate(widget.card);
                Future.delayed(const Duration(milliseconds: 300), () {
                  widget.onAddClicked();
                  Navigator.of(context).pop();
                });
              },
              showDeleteButton: true,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: EditionHeaderCard(
                card: widget.card,
                adicionarButtonTitle: AppLocalizations.of(context)!.update,
                onAddClicked: () {
                  widget.onAddClicked();
                  Navigator.of(context).pop();
                },
                categories: widget.categories,
                onAddCardPressed: widget.onAddCardPressed,
              ),
            ),
            const Expanded(child: SizedBox())
          ],
        ),
      ),
    );
  }
}
