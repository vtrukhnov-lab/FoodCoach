import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/subscription_service.dart';
import '../screens/paywall_screen.dart';
import 'history/daily_history_screen.dart';
import 'history/weekly_history_screen.dart';
import 'history/monthly_history_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _showPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(
          showCloseButton: true,
          source: 'history',
        ),
        fullscreenDialog: true,
      ),
    ).then((result) {
      // Если пользователь купил PRO, обновляем UI
      if (result == true) {
        setState(() {});
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        final isPro = subscriptionProvider.isPro;
        
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Text(
              l10n.history,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(46.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  indicatorWeight: 3,
                  tabs: [
                    // Дневная вкладка - всегда доступна
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.day),
                        ],
                      ),
                    ),
                    
                    // Недельная вкладка - PRO
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.week),
                          if (!isPro) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    // Месячная вкладка - PRO
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.month),
                          if (!isPro) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Дневная история - доступна всем
              const DailyHistoryScreen(),
              
              // Недельная история - только PRO
              isPro 
                ? const WeeklyHistoryScreen()
                : _buildProPlaceholder(
                    title: l10n.weeklyHistory,
                    description: l10n.weeklyHistoryDesc,
                    icon: Icons.calendar_view_week,
                  ),
              
              // Месячная история - только PRO
              isPro
                ? const MonthlyHistoryScreen()
                : _buildProPlaceholder(
                    title: l10n.monthlyHistory,
                    description: l10n.monthlyHistoryDesc,
                    icon: Icons.calendar_month,
                  ),
            ],
          ),
        );
      },
    );
  }
  
  // Заглушка для PRO функций
  Widget _buildProPlaceholder({
    required String title,
    required String description,
    required IconData icon,
  }) {
    final l10n = AppLocalizations.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка с градиентом
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: Colors.grey.shade400,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Заголовок
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Описание
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // PRO badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.proFunction,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Кнопка разблокировки
            ElevatedButton(
              onPressed: _showPaywall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_open, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.unlockProHistory,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Список преимуществ
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildBenefit(l10n.unlimitedHistory),
                  _buildBenefit(l10n.dataExportCSV),
                  _buildBenefit(l10n.detailedAnalytics),
                  _buildBenefit(l10n.periodComparison),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}