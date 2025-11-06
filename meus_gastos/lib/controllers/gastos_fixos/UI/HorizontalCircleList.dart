import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meus_gastos/designSystem/ImplDS.dart';
import 'package:meus_gastos/models/CategoryModel.dart';
import 'package:meus_gastos/services/TranslateService.dart';

class HorizontalCircleList extends StatefulWidget {
  final Function(int) onItemSelected;
  final List<CategoryModel> icons_list_recorrent;
  final int defaultIndexCategory;
  
  const HorizontalCircleList({
    super.key,
    required this.onItemSelected,
    required this.icons_list_recorrent,
    required this.defaultIndexCategory,
  });

  @override
  HorizontalCircleListState createState() => HorizontalCircleListState();
}

class HorizontalCircleListState extends State<HorizontalCircleList> {
  int selectedIndex = 0;
  late ScrollController _scrollController;
  bool _showLeftGradient = false;
  bool _showRightGradient = true;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.defaultIndexCategory;
    _scrollController = ScrollController();
    _scrollController.addListener(_updateGradients);
    
    // Auto-scroll para o item selecionado após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelected(selectedIndex, animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateGradients);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateGradients() {
    setState(() {
      _showLeftGradient = _scrollController.offset > 10;
      _showRightGradient = _scrollController.offset < 
          _scrollController.position.maxScrollExtent - 10;
    });
  }

  void _scrollToSelected(int index, {bool animate = true}) {
    if (!_scrollController.hasClients) return;
    
    final double itemWidth = 90.0; // largura aproximada do item
    final double screenWidth = MediaQuery.of(context).size.width;
    final double targetScroll = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
    
    if (animate) {
      _scrollController.animateTo(
        targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(
        targetScroll.clamp(0.0, _scrollController.position.maxScrollExtent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isMacOS) {
      return _buildMacOSVersion();
    } else {
      return _buildMobileVersion();
    }
  }

  Widget _buildMacOSVersion() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Botão esquerda
          IconButton(
            icon: Icon(
              CupertinoIcons.chevron_left,
              color: _showLeftGradient 
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.3),
            ),
            onPressed: _showLeftGradient ? () {
              _scrollController.animateTo(
                _scrollController.offset - 200,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            } : null,
          ),
          
          // Lista de categorias
          Expanded(child: _buildCategoryList()),
          
          // Botão direita
          IconButton(
            icon: Icon(
              CupertinoIcons.chevron_right,
              color: _showRightGradient 
                  ? Colors.white.withOpacity(0.8)
                  : Colors.white.withOpacity(0.3),
            ),
            onPressed: _showRightGradient ? () {
              _scrollController.animateTo(
                _scrollController.offset + 200,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileVersion() {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          _buildCategoryList(),
          
          // Gradiente esquerdo
          if (_showLeftGradient)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.card.withOpacity(0.3),
                        AppColors.card.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          
          // Gradiente direito
          if (_showRightGradient)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Container(
                  width: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        AppColors.card.withOpacity(0.3),
                        AppColors.card.withOpacity(0.0),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: widget.icons_list_recorrent.length,
      itemBuilder: (context, index) {
        final category = widget.icons_list_recorrent[index];
        final isSelected = selectedIndex == index;
        
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            widget.onItemSelected(index);
            _scrollToSelected(index);
            HapticFeedback.lightImpact();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Container do ícone
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 60 : 54,
                  height: isSelected ? 60 : 54,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.black.withOpacity(0.4)
                        : Colors.black.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? category.color.withOpacity(0.8)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: AnimatedScale(
                    scale: isSelected ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      category.icon,
                      color: isSelected 
                          ? category.color 
                          : category.color.withOpacity(0.6),
                      size: isSelected ? 28 : 24,
                    ),
                  ),
                ),
                
                const SizedBox(height: 6),
                
                // Nome da categoria
                SizedBox(
                  width: 75,
                  child: Text(
                    TranslateService.getTranslatedCategoryUsingModel(
                      context,
                      category,
                    ),
                    style: TextStyle(
                      fontSize: isSelected ? 11 : 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? Colors.white 
                          : Colors.white.withOpacity(0.7),
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}