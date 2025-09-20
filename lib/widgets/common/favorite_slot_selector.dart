// lib/widgets/common/favorite_slot_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/quick_favorites.dart';
import '../../screens/paywall_screen.dart';

/// Dialog for selecting a favorite slot
class FavoriteSlotSelector extends StatelessWidget {
  final QuickFavoritesManager favoritesManager;
  final bool isPro;

  const FavoriteSlotSelector({
    super.key,
    required this.favoritesManager,
    required this.isPro,
  });

  static Future<int?> show({
    required BuildContext context,
    required QuickFavoritesManager favoritesManager,
    required bool isPro,
  }) async {
    return await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => FavoriteSlotSelector(
        favoritesManager: favoritesManager,
        isPro: isPro,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            l10n.selectFavoriteSlot,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          // Slots
          for (int i = 0; i < 3; i++) ...[
            _SlotOption(
              slot: i,
              isLocked: !isPro && i > 0,
              currentFavorite: favoritesManager.favorites[i],
              l10n: l10n,
              onTap: (slot) {
                HapticFeedback.lightImpact();
                Navigator.pop(context, slot);
              },
              onProRequired: (slot) async {
                // КЛЮЧЕВОЕ ИЗМЕНЕНИЕ: НЕ закрываем селектор до пейвола
                HapticFeedback.lightImpact();
                
                // Открываем пейвол и ждем результат
                final upgraded = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaywallScreen(source: 'favorite_slot_selector'),
                    fullscreenDialog: true,
                  ),
                );

                // Если пользователь успешно апгрейднулся - возвращаем выбранный слот
                if (upgraded == true && context.mounted) {
                  Navigator.pop(context, slot);
                }
                // Если не апгрейднулся - просто остаемся в селекторе
              },
            ),
            if (i < 2) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

/// Individual slot option widget
class _SlotOption extends StatelessWidget {
  final int slot;
  final bool isLocked;
  final QuickFavorite? currentFavorite;
  final AppLocalizations l10n;
  final Function(int) onTap;
  final ValueChanged<int> onProRequired; // Изменили тип - теперь принимает слот

  const _SlotOption({
    required this.slot,
    required this.isLocked,
    required this.currentFavorite,
    required this.l10n,
    required this.onTap,
    required this.onProRequired,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.purple.shade50.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple.shade100,
            child: const Icon(Icons.lock, color: Colors.purple),
          ),
          title: Text('${l10n.slot} ${slot + 1} (PRO)'),
          subtitle: Text(l10n.upgradeToUnlock),
          onTap: () => onProRequired(slot), // Передаем номер слота
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: currentFavorite != null 
          ? Colors.orange.shade50 
          : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: currentFavorite != null 
            ? Colors.orange.shade200 
            : Colors.green.shade200,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: currentFavorite != null 
            ? Colors.orange.shade100 
            : Colors.green.shade100,
          child: Icon(
            currentFavorite != null ? Icons.star : Icons.add,
            color: currentFavorite != null 
              ? Colors.orange.shade600 
              : Colors.green.shade600,
          ),
        ),
        title: Text('${l10n.slot} ${slot + 1}'),
        subtitle: Text(
          currentFavorite?.label ?? l10n.emptySlot,
          style: TextStyle(
            fontSize: 13,
            color: currentFavorite != null 
              ? Colors.grey.shade700 
              : Colors.grey.shade500,
          ),
        ),
        trailing: currentFavorite != null
          ? PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onSelected: (value) {
                if (value == 'change') {
                  onTap(slot);
                } else if (value == 'remove') {
                  // TODO: Implement remove functionality
                  HapticFeedback.lightImpact();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'change',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, size: 20),
                      const SizedBox(width: 12),
                      Text(l10n.changeFavorite),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'remove',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, size: 20, color: Colors.red),
                      const SizedBox(width: 12),
                      Text(l10n.removeFavorite, 
                        style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            )
          : Icon(
              Icons.chevron_right, 
              color: Colors.grey.shade400,
            ),
        onTap: () => onTap(slot),
      ),
    );
  }
}