// import 'package:meus_gastos/controllers/Goals/Data/GoalsService.dart';
// import 'package:meus_gastos/controllers/gastos_fixos/fixedExpensesService.dart';
// import 'package:meus_gastos/services/TranslateService.dart';
// import 'dart:math';
// import 'package:flutter/services.dart';
// import 'package:uuid/uuid.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:meus_gastos/designSystem/ImplDS.dart';
// import 'package:meus_gastos/services/CategoryService.dart';
// import 'package:meus_gastos/models/CategoryModel.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:meus_gastos/l10n/app_localizations.dart';
// import 'package:meus_gastos/controllers/CategoryCreater/Components/AddCategoryHorizontalCircleList.dart';

// class Categorycreater extends StatefulWidget {
//   final VoidCallback onCategoryAdded;

//   const Categorycreater({super.key, required this.onCategoryAdded});

//   @override
//   State<Categorycreater> createState() => _CategorycreaterState();
// }

// class _CategorycreaterState extends State<Categorycreater> with SingleTickerProviderStateMixin {
//   late TextEditingController categoriaController;
//   late Color _currentColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
  
//   int selectedIndex = 0;
//   List<CategoryModel> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     categoriaController = TextEditingController();
//     _loadCategories();
    
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
    
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
    
//     _animationController.forward();
//   }

//   void _loadCategories() async {
//     final categories = await CategoryService().getAllCategoriesAvaliable();
//     setState(() {
//       _categories = categories;
//     });
//   }

//   @override
//   void dispose() {
//     categoriaController.dispose();
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _hideKeyboard() {
//     FocusScope.of(context).unfocus();
//   }

//   void _pickColor(BuildContext context) {
//     showCupertinoModalPopup(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//           height: 420,
//           padding: const EdgeInsets.all(20),
//           decoration: const BoxDecoration(
//             color: AppColors.card,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 AppLocalizations.of(context)!.chooseColor,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ColorPicker(
//                 pickerColor: _currentColor,
//                 onColorChanged: (Color color) {
//                   setState(() {
//                     _currentColor = color;
//                   });
//                 },
//                 showLabel: false,
//                 pickerAreaHeightPercent: 0.6,
//                 displayThumbColor: false,
//                 enableAlpha: false,
//                 paletteType: PaletteType.hsv,
//                 pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48,
//                 child: CupertinoButton(
//                   color: AppColors.button,
//                   borderRadius: BorderRadius.circular(12),
//                   padding: EdgeInsets.zero,
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text(
//                     AppLocalizations.of(context)!.select,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void adicionar() async {
//     // Busca todas as categorias antes de adicionar
//     List<CategoryModel> allCategories = await CategoryService().getAllCategories();
    
//     // Separa AddCategory
//     List<CategoryModel> withoutAddCategory = allCategories
//         .where((cat) => cat.id != 'AddCategory')
//         .toList();
    
//     CategoryModel? addCategory = allCategories.firstWhere(
//       (cat) => cat.id == 'AddCategory',
//       orElse: () => CategoryModel(
//         id: 'AddCategory',
//         color: AppColors.button,
//         icon: Icons.add,
//         name: 'AddCategory',
//         frequency: 0,
//       ),
//     );

//     // Cria nova categoria
//     CategoryModel category = CategoryModel(
//       id: const Uuid().v4(),
//       color: _currentColor,
//       icon: accountIcons[selectedIndex],
//       name: categoriaController.text,
//       frequency: 0,
//     );

//     // Adiciona a nova categoria antes de AddCategory
//     withoutAddCategory.add(category);
//     List<CategoryModel> newOrderedList = [...withoutAddCategory, addCategory];
    
//     // Salva a nova ordem completa
//     await CategoryService().saveOrderedCategories(newOrderedList);
//     widget.onCategoryAdded();
    
//     categoriaController.clear();
    
//     // Atualiza o estado diretamente sem piscar
//     setState(() {
//       _currentColor = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
//       selectedIndex = 0;
//       _categories = newOrderedList;
//     });
//   }

// Future<void> _reorderCategories(int oldIndex, int newIndex) async {
//   // Ajusta o índice
//   if (newIndex > oldIndex) {
//     newIndex -= 1;
//   }
  
//   // Trabalha com a lista local _categories em vez de buscar do SharedPreferences
//   List<CategoryModel> withoutAddCategory = _categories
//       .where((cat) => cat.id != 'AddCategory')
//       .toList();
  
//   CategoryModel? addCategory = _categories.firstWhere(
//     (cat) => cat.id == 'AddCategory',
//     orElse: () => CategoryModel(
//       id: 'AddCategory',
//       color: AppColors.button,
//       icon: Icons.add,
//       name: 'AddCategory',
//       frequency: 0,
//     ),
//   );
  
//   // Reordena apenas as categorias sem AddCategory
//   final item = withoutAddCategory.removeAt(oldIndex);
//   withoutAddCategory.insert(newIndex, item);
  
//   // Reconstroi a lista completa: categorias reordenadas + AddCategory no final
//   List<CategoryModel> newOrderedList = [...withoutAddCategory, addCategory];
  
//   // Atualiza o estado IMEDIATAMENTE (sem await)
//   setState(() {
//     _categories = newOrderedList;
//   });
  
//   // Salva em background (sem bloquear a UI)
//   CategoryService().saveOrderedCategories(newOrderedList).then((_) {
//     widget.onCategoryAdded();
//   });
  
//   HapticFeedback.mediumImpact();
// }

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Container(
//           decoration: const BoxDecoration(
//             color: AppColors.background1,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header maior e sem sombra
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//                 decoration: BoxDecoration(
//                   color: AppColors.card.withOpacity(0.5),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     CupertinoButton(
//                       padding: EdgeInsets.zero,
//                       minSize: 0,
//                       onPressed: () => Navigator.pop(context),
//                       child: const Icon(
//                         CupertinoIcons.xmark_circle_fill,
//                         color: Colors.white54,
//                         size: 24,
//                       ),
//                     ),
//                     Text(
//                       AppLocalizations.of(context)!.createCategory,
//                       style: const TextStyle(
//                         fontSize: 17,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     const SizedBox(width: 24),
//                   ],
//                 ),
//               ),

//               // Conteúdo principal - tudo em um scroll
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Seletor de ícones
//                       AddCategoryHorizontalCircleList(
//                         onItemSelected: (index) {
//                           setState(() {
//                             selectedIndex = index;
//                           });
//                           HapticFeedback.lightImpact();
//                         },
//                       ),
                      
//                       const SizedBox(height: 16),
                      
//                       // Campo de nome da categoria
//                       Container(
//                         decoration: BoxDecoration(
//                           color: AppColors.card,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: CupertinoTextField(
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                           decoration: BoxDecoration(
//                             color: AppColors.card,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                           placeholder: AppLocalizations.of(context)!.category,
//                           placeholderStyle: TextStyle(
//                             color: Colors.white.withOpacity(0.4),
//                             fontSize: 16,
//                           ),
//                           controller: categoriaController,
//                           inputFormatters: [
//                             LengthLimitingTextInputFormatter(15),
//                           ],
//                           textCapitalization: TextCapitalization.sentences,
//                         ),
//                       ),
                      
//                       const SizedBox(height: 12),
                      
//                       // Seletor de cor compacto sem sombra
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//                         decoration: BoxDecoration(
//                           color: AppColors.card,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               AppLocalizations.of(context)!.chooseColor,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: () {
//                                 _pickColor(context);
//                                 HapticFeedback.lightImpact();
//                               },
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   color: _currentColor,
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: Colors.white.withOpacity(0.2),
//                                     width: 2,
//                                   ),
//                                 ),
//                                 height: 36,
//                                 width: 36,
//                                 child: Icon(
//                                   CupertinoIcons.eyedropper,
//                                   color: _currentColor.computeLuminance() > 0.5 
//                                       ? Colors.black54 
//                                       : Colors.white70,
//                                   size: 18,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
                      
//                       const SizedBox(height: 12),
                      
//                       // Botão adicionar
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48,
//                         child: CupertinoButton(
//                           color: AppColors.button,
//                           borderRadius: BorderRadius.circular(12),
//                           padding: EdgeInsets.zero,
//                           onPressed: () {
//                             if (categoriaController.text.isNotEmpty) {
//                               adicionar();
//                               HapticFeedback.mediumImpact();
//                               _hideKeyboard();
//                             }
//                           },
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(CupertinoIcons.add_circled, size: 18),
//                               const SizedBox(width: 8),
//                               Text(
//                                 AppLocalizations.of(context)!.addCategory,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
                      
//                       const SizedBox(height: 12),
//                       const Divider(),
//                       const SizedBox(height: 12),
                      
//                       // Lista de categorias sem sombras
//                       Container(
//                         decoration: BoxDecoration(
//                           color: AppColors.card.withOpacity(0.3),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: _categories.isEmpty || _categories.length <= 1
//                             ? Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(20),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Icon(
//                                         CupertinoIcons.square_stack_3d_up,
//                                         size: 40,
//                                         color: Colors.white.withOpacity(0.3),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         "Nenhuma categoria criada",
//                                         style: TextStyle(
//                                           color: Colors.white.withOpacity(0.5),
//                                           fontSize: 13,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               )
//                             : Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   Padding(
//                                     padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
//                                     child: Row(
//                                       children: [
//                                         Icon(
//                                           CupertinoIcons.list_bullet,
//                                           size: 16,
//                                           color: Colors.white.withOpacity(0.6),
//                                         ),
//                                         const SizedBox(width: 6),
//                                         Text(
//                                           "Minhas Categorias",
//                                           style: TextStyle(
//                                             color: Colors.white.withOpacity(0.6),
//                                             fontSize: 13,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                         const Spacer(),
//                                         Icon(
//                                           CupertinoIcons.arrow_up_arrow_down,
//                                           size: 14,
//                                           color: Colors.white.withOpacity(0.4),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   // Lista sem scroll, usa o scroll do pai
//                                   ReorderableListView.builder(
//                                     shrinkWrap: true,
//                                     physics: const NeverScrollableScrollPhysics(),
//                                     padding: const EdgeInsets.only(bottom: 14, left: 10, right: 10),
//                                     buildDefaultDragHandles: false,
//                                     itemCount: _categories.length - 1,
//                                     onReorder: _reorderCategories,
//                                     proxyDecorator: (child, index, animation) {
//                                       return Material(
//                                         color: Colors.transparent,
//                                         child: child,
//                                       );
//                                     },
//                                     itemBuilder: (context, index) {
//                                       final category = _categories[index];
//                                       return Container(
//                                         key: ValueKey(category.id),
//                                         margin: const EdgeInsets.only(bottom: 10),
//                                         decoration: BoxDecoration(
//                                           color: AppColors.card,
//                                           borderRadius: BorderRadius.circular(14),
//                                         ),
//                                         child: Padding(
//                                           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
//                                           child: Row(
//                                             children: [
//                                               // Drag handle - ÁREA MAIOR E MAIS CLICÁVEL
//                                               ReorderableDragStartListener(
//                                                 index: index,
//                                                 child: Container(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//                                                   margin: const EdgeInsets.only(right: 4),
//                                                   child: Icon(
//                                                     CupertinoIcons.line_horizontal_3,
//                                                     color: Colors.white.withOpacity(0.4),
//                                                     size: 30,
//                                                   ),
//                                                 ),
//                                               ),
//                                               // Ícone da categoria - FUNDO PRETO
//                                               Container(
//                                                 width: 40,
//                                                 height: 40,
//                                                 decoration: BoxDecoration(
//                                                   color: Colors.black.withOpacity(0.4),
//                                                   borderRadius: BorderRadius.circular(8)
//                                                 ),
//                                                 child: Icon(
//                                                   category.icon,
//                                                   color: category.color,
//                                                   size: 20,
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 14),
//                                               // Nome da categoria
//                                               Expanded(
//                                                 child: Text(
//                                                   TranslateService.getTranslatedCategoryUsingModel(
//                                                     context,
//                                                     category,
//                                                   ),
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontWeight: FontWeight.w600,
//                                                     fontSize: 16,
//                                                     letterSpacing: 0.2,
//                                                   ),
//                                                   overflow: TextOverflow.ellipsis,
//                                                 ),
//                                               ),
//                                               // Botão deletar
//                                               CupertinoButton(
//                                                 padding: const EdgeInsets.all(8),
//                                                 minSize: 0,
//                                                 onPressed: () async {
//                                                   _hideKeyboard();
//                                                   final shouldDelete = await showCupertinoDialog<bool>(
//                                                     context: context,
//                                                     builder: (context) => CupertinoAlertDialog(
//                                                       title: const Text("Excluir categoria"),
//                                                       content: const Text(
//                                                         "Tem certeza que deseja excluir esta categoria?",
//                                                       ),
//                                                       actions: [
//                                                         CupertinoDialogAction(
//                                                           child: const Text("Cancelar"),
//                                                           onPressed: () => Navigator.pop(context, false),
//                                                         ),
//                                                         CupertinoDialogAction(
//                                                           isDestructiveAction: true,
//                                                           onPressed: () => Navigator.pop(context, true),
//                                                           child: const Text("Excluir"),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );
                                                  
//                                                   if (shouldDelete == true) {
//                                                     await CategoryService().deleteCategory(category.id);
//                                                     widget.onCategoryAdded();
                                                    
//                                                     // Recarrega as categorias
//                                                     final updatedCategories = await CategoryService().getAllCategoriesAvaliable();
//                                                     setState(() {
//                                                       _categories = updatedCategories;
//                                                     });
//                                                     HapticFeedback.mediumImpact();
//                                                   }
//                                                 },
//                                                 child: Container(
//                                                   padding: const EdgeInsets.all(8),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.redAccent.withOpacity(0.1),
//                                                     borderRadius: BorderRadius.circular(10),
//                                                   ),
//                                                   child: const Icon(
//                                                     CupertinoIcons.trash,
//                                                     color: Colors.redAccent,
//                                                     size: 20,
//                                                   ),
//                                                 ),
//                                               ),
//                                               const SizedBox(width: 4),
//                                             ],
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ],
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }