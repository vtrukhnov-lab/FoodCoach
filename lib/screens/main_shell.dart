import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';

// Экраны
import 'home_screen.dart';
import 'history_screen.dart';
import 'notification_settings_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Инициализируем экраны один раз
  late final List<Widget> _screens;
  final AnalyticsService _analytics = AnalyticsService();
  static const List<String> _tabKeys = <String>[
    'home',
    'history',
    'notifications',
    'reports',
    'settings',
  ];
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const HistoryScreen(),
      const NotificationSettingsScreen(),
      Container(), // Пустой контейнер вместо текста
      const SettingsScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _analytics.logScreenView(
        screenName: 'main_${_tabKeys[_currentIndex]}',
        screenClass: 'MainShell',
      );
    });
  }

  void _onTabTapped(int index) {
    final String tabKey = _tabKeys[index];
    _analytics.logNavigationTabSelected(tab: tabKey);

    // Если это неработающая вкладка (только 3), показываем сообщение
    if (index == 3) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dailyReportComingSoon),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
    HapticFeedback.lightImpact();

    _analytics.logScreenView(
      screenName: 'main_${_tabKeys[index]}',
      screenClass: 'MainShell',
    );
  }

  void _showAddMenu() {
    HapticFeedback.mediumImpact();
    _analytics.logQuickAddMenuOpened();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddMenuSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      extendBody: true, // ВАЖНО: позволяет контенту идти под навигацию
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      
      // FAB - центральная кнопка
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Bottom Navigation
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Левая часть
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: l10n.home,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: l10n.history,
                index: 1,
              ),
              
              // Пространство для FAB
              const SizedBox(width: 40),
              
              // Правая часть
              _buildNavItem(
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: l10n.notificationsSection,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: l10n.settings,
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6), // Уменьшено с 8
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
                size: 26, // Уменьшено с 28
              ),
              const SizedBox(height: 2), // Уменьшено с 4
              Text(
                label,
                style: TextStyle(
                  fontSize: 10, // Уменьшено с 11
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Модальное меню добавления
class _AddMenuSheet extends StatelessWidget {
  const _AddMenuSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Индикатор
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Заголовок
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              l10n.quickAdd,
              style: theme.textTheme.titleLarge,
            ),
          ),
          
          // Опции
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Первая строка
                Row(
                  children: [
                    _buildAddOption(
                      context: context,
                      icon: Icons.water_drop,
                      label: l10n.water,
                      color: Colors.blue,
                      route: '/liquids',
                    ),
                    const SizedBox(width: 12),
                    _buildAddOption(
                      context: context,
                      icon: Icons.coffee,
                      label: l10n.hotDrinks,
                      color: Colors.brown,
                      route: '/hot_drinks',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Вторая строка
                Row(
                  children: [
                    _buildAddOption(
                      context: context,
                      icon: Icons.bolt,
                      label: l10n.electrolytes,
                      color: Colors.orange,
                      route: '/electrolytes',
                    ),
                    const SizedBox(width: 12),
                    _buildAddOption(
                      context: context,
                      icon: Icons.local_bar,
                      label: l10n.alcohol,
                      color: Colors.purple,
                      route: '/alcohol',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Третья строка
                Row(
                  children: [
                    _buildAddOption(
                      context: context,
                      icon: Icons.fitness_center,
                      label: l10n.sports,
                      color: Colors.green,
                      route: '/sports',
                    ),
                    const SizedBox(width: 12),
                    _buildAddOption(
                      context: context,
                      icon: Icons.medication,
                      label: l10n.supplements,
                      color: Colors.teal,
                      route: '/supplements',
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Четвертая строка - Food
                Row(
                  children: [
                    _buildAddOption(
                      context: context,
                      icon: Icons.restaurant,
                      label: l10n.foodCatalog,
                      color: Colors.deepOrange,
                      route: '/food',
                    ),
                    const SizedBox(width: 12),
                    _buildAddOption(
                      context: context,
                      icon: Icons.shopping_cart, // 🛒 иконка корзины
                      label: l10n.searchCatalog,
                      color: Colors.indigo,
                      route: '/openfood_catalog',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required String route,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, route);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}