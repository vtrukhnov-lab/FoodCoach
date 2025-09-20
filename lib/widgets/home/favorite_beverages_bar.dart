// lib/widgets/home/favorite_beverages_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/alcohol_intake.dart';
import '../../models/quick_favorites.dart';
import '../../providers/hydration_provider.dart';
import '../../screens/paywall_screen.dart';
import '../../services/alcohol_service.dart';
import '../../services/hri_service.dart';
import '../../services/subscription_service.dart';
import '../../services/units_service.dart';
import '../../widgets/common/volume_selection_dialog.dart';
import '../../data/catalog_item.dart';

class FavoriteBeveragesBar extends StatefulWidget {
  final VoidCallback onUpdate;
  const FavoriteBeveragesBar({super.key, required this.onUpdate});

  @override
  State<FavoriteBeveragesBar> createState() => _FavoriteBeveragesBarState();
}

class _FavoriteBeveragesBarState extends State<FavoriteBeveragesBar> {
  final QuickFavoritesManager _favoritesManager = QuickFavoritesManager();
  int? _pressedIndex;
  bool? _lastKnownProStatus;

  @override
  void initState() {
    super.initState();
    _favoritesManager.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesManager.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  // Создаем CatalogItem из QuickFavorite для диалога выбора объема
  CatalogItem _createCatalogItemFromFavorite(QuickFavorite favorite) {
    // Собираем свойства напитка
    Map<String, dynamic> properties = {
      'type': favorite.type,
      'hydration': 1.0,
      'defaultVolume': {
        'metric': favorite.volumeMl ?? 250,
        'imperial': ((favorite.volumeMl ?? 250) / 29.5735).round(),
      },
    };

    // Добавляем электролиты если есть
    if (favorite.sodiumMg != null && favorite.sodiumMg! > 0) {
      properties['sodium'] = favorite.sodiumMg;
    }
    if (favorite.potassiumMg != null && favorite.potassiumMg! > 0) {
      properties['potassium'] = favorite.potassiumMg;
    }
    if (favorite.magnesiumMg != null && favorite.magnesiumMg! > 0) {
      properties['magnesium'] = favorite.magnesiumMg;
    }

    // Добавляем кофеин для горячих напитков
    final caffeine = favorite.metadata?['caffeine'];
    if (caffeine != null && caffeine > 0) {
      final baseVolume = favorite.volumeMl ?? 250;
      properties['caffeineMgPer100ml'] = (caffeine * 100 / baseVolume).round();
    }

    // Добавляем алкогольные свойства если нужно
    if (favorite.type == 'alcohol') {
      properties['abv'] = favorite.metadata?['abv'] ?? 5.0;
    }

    // ВАЖНО: Берем правильное имя напитка из метаданных или label
    final drinkName = favorite.metadata?['itemName'] ?? favorite.label;

    return CatalogItem(
      id: favorite.id,
      getName: (l10n) => drinkName,  // Возвращаем сохраненное имя напитка
      icon: favorite.emoji.isNotEmpty ? favorite.emoji : _getDefaultIcon(favorite.type),
      properties: properties,
      isPro: false,
    );
  }

  // Обработка нажатия на избранное - открываем диалог выбора объема
  Future<void> _handleFavoriteTap(QuickFavorite favorite, int index) async {
    setState(() => _pressedIndex = index);
    
    final units = UnitsService.instance.units;
    
    // Создаем CatalogItem из избранного
    final item = _createCatalogItemFromFavorite(favorite);
    
    // Определяем нужно ли показывать электролиты
    final showElectrolytes = favorite.type == 'electrolyte' || 
                            (favorite.sodiumMg != null && favorite.sodiumMg! > 0) ||
                            (favorite.potassiumMg != null && favorite.potassiumMg! > 0) ||
                            (favorite.magnesiumMg != null && favorite.magnesiumMg! > 0);
    
    // Показываем диалог выбора объема для ВСЕХ напитков
    await VolumeSelectionDialog.show(
      context: context,
      item: item,
      units: units,
      showElectrolytes: showElectrolytes,
      sliderColor: _getDrinkColor(favorite.type),
      onConfirm: (volumeMl) async {
        await _applyDrink(favorite, volumeMl);
      },
      onSaveToFavorites: (volumeMl) {
        // Уже в избранном - показываем сообщение
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.alreadyInFavorites),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
    );
    
    if (mounted) {
      setState(() => _pressedIndex = null);
    }
  }

  // Применяем напиток с выбранным объемом
  Future<void> _applyDrink(QuickFavorite favorite, double volumeMl) async {
    final hydrationProvider = Provider.of<HydrationProvider>(context, listen: false);
    final hriService = Provider.of<HRIService>(context, listen: false);
    final units = Provider.of<UnitsService>(context, listen: false);

    if (favorite.type == 'alcohol') {
      // Обработка алкоголя
      final alcoholService = Provider.of<AlcoholService>(context, listen: false);
      final alcoholTypeString = favorite.metadata?['alcoholType'] ?? 'beer';
      final alcoholType = AlcoholType.values.firstWhere(
        (type) => type.key == alcoholTypeString,
        orElse: () => AlcoholType.beer,
      );

      final intake = AlcoholIntake(
        timestamp: DateTime.now(),
        type: alcoholType,
        volumeMl: volumeMl,
        abv: (favorite.metadata?['abv'] ?? 5.0).toDouble(),
      );
      alcoholService.addIntake(intake);
      
    } else if (favorite.type == 'coffee' || favorite.type == 'tea' || favorite.type == 'hot') {
      // Горячие напитки - добавляем как воду
      hydrationProvider.addIntake(
        'water',
        volumeMl.round(),
        sodium: 0,
        potassium: 0,
        magnesium: 0,
        source: 'favorite_beverage_${favorite.type}',
      );
      
      // Рассчитываем пропорциональный кофеин
      final baseCaffeine = favorite.metadata?['caffeine'] as int?;
      final baseVolume = favorite.volumeMl ?? 250;
      if (baseCaffeine != null && baseCaffeine > 0 && baseVolume > 0) {
        final actualCaffeine = (baseCaffeine * volumeMl / baseVolume).round();
        await hriService.addCaffeineIntake(actualCaffeine.toDouble());
      }
      
    } else if (favorite.type == 'electrolyte' || 
               favorite.sodiumMg != null || 
               favorite.potassiumMg != null || 
               favorite.magnesiumMg != null) {
      // Напитки с электролитами - рассчитываем пропорциональные количества
      final baseVolume = favorite.volumeMl ?? 250;
      final multiplier = volumeMl / baseVolume;
      
      hydrationProvider.addIntake(
        favorite.type == 'electrolyte' ? 'electrolyte' : 'water',
        volumeMl.round(),
        sodium: ((favorite.sodiumMg ?? 0) * multiplier).round(),
        potassium: ((favorite.potassiumMg ?? 0) * multiplier).round(),
        magnesium: ((favorite.magnesiumMg ?? 0) * multiplier).round(),
        source: 'favorite_beverage_${favorite.type}',
      );
    } else {
      // Обычные напитки без особых свойств
      hydrationProvider.addIntake(
        favorite.type,
        volumeMl.round(),
        sodium: 0,
        potassium: 0,
        magnesium: 0,
        source: 'favorite_beverage_${favorite.type}',
      );
    }

    widget.onUpdate();
    HapticFeedback.lightImpact();

    // Показываем сообщение об успехе
    final l10n = AppLocalizations.of(context);
    final displayVolume = units.formatVolume(volumeMl.round());
    final drinkName = favorite.metadata?['itemName'] ?? favorite.label;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$drinkName - $displayVolume ${l10n.addedSuccessfully}',
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleEmptySlotTap() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.createFavoriteHint),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleProSlotTap() async {
    HapticFeedback.lightImpact();
    
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(source: 'favorite_beverages_bar'),
        fullscreenDialog: true
      ),
    );
    
    if (result == true && mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(l10n.welcomeToPro),
            ],
          ),
          backgroundColor: Colors.purple.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Слушаем изменения PRO статуса
    final isPro = context.select<SubscriptionProvider, bool>((provider) => provider.isPro);
    
    // Переинициализируем менеджер избранного при изменении PRO статуса
    if (_lastKnownProStatus != isPro) {
      _lastKnownProStatus = isPro;
      _favoritesManager.init(isPro).then((_) {
        if (mounted) setState(() {});
      });
    }

    final favorites = _favoritesManager.favorites;
    
    // Адаптивные размеры на основе ширины экрана
    final cardHeight = screenWidth * 0.28; // ~28% от ширины экрана (было 85px)
    final horizontalPadding = screenWidth * 0.01; // 1% от ширины
    final cardSpacing = screenWidth * 0.01; // 1% между карточками
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 3),
      child: SizedBox(
        height: cardHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(3, (index) {
            final isLocked = !isPro && index > 0;
            final favorite = favorites[index];
            
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 0 : cardSpacing,
                  right: index == 2 ? 0 : cardSpacing,
                ),
                child: isLocked
                    ? _buildProLockedSlot(isDarkMode, l10n, cardHeight)
                    : favorite != null
                        ? _buildFilledSlot(favorite, index, isDarkMode, cardHeight)
                        : _buildEmptySlot(l10n, isDarkMode, cardHeight),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildFilledSlot(QuickFavorite favorite, int index, bool isDarkMode, double cardHeight) {
    final isPressed = _pressedIndex == index;
    final color = _getDrinkColor(favorite.type);
    final icon = favorite.emoji.isNotEmpty ? favorite.emoji : _getDefaultIcon(favorite.type);
    final drinkName = favorite.metadata?['itemName'] ?? favorite.label;
    
    // Адаптивные размеры на основе высоты карточки
    final iconSize = cardHeight * 0.25; // 25% от высоты карточки
    final textSize = cardHeight * 0.1; // 10% от высоты карточки
    final verticalSpacing = cardHeight * 0.08; // 8% для отступов
    final horizontalPadding = cardHeight * 0.08; // 8% для горизонтальных отступов

    return AnimatedScale(
      scale: isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressedIndex = index),
        onTapUp: (_) => _handleFavoriteTap(favorite, index),
        onTapCancel: () => setState(() => _pressedIndex = null),
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(cardHeight * 0.2), // 20% от высоты
            border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
            boxShadow: isPressed ? [] : [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Иконка напитка
              Text(icon, style: TextStyle(fontSize: iconSize)),
              SizedBox(height: verticalSpacing),
              // Название напитка (может быть в 2 строки)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Text(
                  drinkName,
                  style: TextStyle(
                    fontSize: textSize,
                    fontWeight: FontWeight.w600,
                    color: color.withValues(alpha: 0.9),
                    height: 1.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySlot(AppLocalizations l10n, bool isDarkMode, double cardHeight) {
    // Адаптивные размеры
    final iconSize = cardHeight * 0.28; // 28% от высоты карточки
    final textSize = cardHeight * 0.11; // 11% от высоты карточки
    final iconPadding = cardHeight * 0.1; // 10% для padding иконки
    final verticalSpacing = cardHeight * 0.08; // 8% для отступов
    
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [Colors.grey[850]!.withValues(alpha: 0.5), Colors.grey[900]!.withValues(alpha: 0.3)]
              : [Colors.grey[50]!, Colors.white],
        ),
        borderRadius: BorderRadius.circular(cardHeight * 0.2),
        border: Border.all(
          color: isDarkMode 
              ? Colors.grey[700]!.withValues(alpha: 0.5) 
              : Colors.grey[300]!.withValues(alpha: 0.8),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: _handleEmptySlotTap,
        borderRadius: BorderRadius.circular(cardHeight * 0.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_rounded,
                size: iconSize,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[400],
              ),
            ),
            SizedBox(height: verticalSpacing),
            Text(
              l10n.addFavorite,
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProLockedSlot(bool isDarkMode, AppLocalizations l10n, double cardHeight) {
    // Адаптивные размеры
    final iconSize = cardHeight * 0.26; // 26% от высоты карточки
    final badgeTextSize = cardHeight * 0.11; // 11% от высоты карточки
    final iconPadding = cardHeight * 0.08; // 8% для padding иконки
    final verticalSpacing = cardHeight * 0.06; // 6% для отступов
    final badgePaddingH = cardHeight * 0.12; // 12% горизонтальный padding бейджа
    final badgePaddingV = cardHeight * 0.035; // 3.5% вертикальный padding бейджа
    
    return Container(
      height: cardHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400.withValues(alpha: 0.8),
            Colors.purple.shade600.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(cardHeight * 0.2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleProSlotTap,
          borderRadius: BorderRadius.circular(cardHeight * 0.2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: iconSize,
                ),
              ),
              SizedBox(height: verticalSpacing),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: badgePaddingH, 
                  vertical: badgePaddingV
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(cardHeight * 0.15),
                ),
                child: Text(
                  'PRO',
                  style: TextStyle(
                    fontSize: badgeTextSize,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDefaultIcon(String type) {
    if (type == 'alcohol') {
      return '🍺';
    }
    
    switch (type) {
      case 'water': return '💧';
      case 'electrolyte': return '⚡';
      case 'coffee': return '☕';
      case 'tea': return '🍵';
      case 'hot': return '☕';
      case 'broth': return '🍲';
      case 'juice': return '🧃';
      case 'milk': return '🥛';
      case 'soda': return '🥤';
      default: return '🥤';
    }
  }

  Color _getDrinkColor(String type) {
    switch (type) {
      case 'water': return const Color(0xFF4A90E2);
      case 'electrolyte': return const Color(0xFFFFA502);
      case 'coffee': return const Color(0xFF8B4513);
      case 'tea': return const Color(0xFF4CAF50);
      case 'hot': return const Color(0xFF8B4513);
      case 'broth': return const Color(0xFFFF6B6B);
      case 'alcohol': return const Color(0xFFFFB300);
      case 'juice': return const Color(0xFFFF9800);
      case 'milk': return const Color(0xFFF5F5DC);
      case 'soda': return const Color(0xFF9C27B0);
      default: return Colors.grey;
    }
  }
}