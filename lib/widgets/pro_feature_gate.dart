import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/feature_gate_service.dart';
import '../services/subscription_service.dart';
import '../screens/paywall_screen.dart';

/// Виджет-обёртка для PRO функций с мягким гейтингом
class ProFeatureGate extends StatelessWidget {
  final AppFeature feature;
  final Widget child;
  final bool showLockOverlay; // Показывать оверлей с замком
  final bool allowTap; // Разрешить тап для открытия пейвола
  final String? customMessage; // Кастомное сообщение
  
  const ProFeatureGate({
    super.key,
    required this.feature,
    required this.child,
    this.showLockOverlay = true,
    this.allowTap = true,
    this.customMessage,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        final featureGate = FeatureGateService.instance;
        final isAvailable = featureGate.isFeatureAvailable(feature);
        
        if (isAvailable) {
          // Функция доступна - показываем контент как есть
          return child;
        }
        
        // Функция недоступна - показываем с блокировкой
        return GestureDetector(
          onTap: allowTap ? () => _showPaywall(context) : null,
          child: Stack(
            children: [
              // Основной контент (может быть затемнён)
              Opacity(
                opacity: showLockOverlay ? 0.5 : 1.0,
                child: AbsorbPointer(
                  absorbing: true, // Блокируем взаимодействие
                  child: child,
                ),
              ),
              
              // Оверлей с замком
              if (showLockOverlay)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Иконка замка с градиентом PRO
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.lock,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Название функции
                          Text(
                            'PRO функция',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Описание функции
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              customMessage ?? 
                              FeatureGateService.getFeatureDescription(feature),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          
                          if (allowTap) ...[
                            const SizedBox(height: 16),
                            
                            // Кнопка разблокировки
                            ElevatedButton(
                              onPressed: () => _showPaywall(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFD700),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              child: const Text(
                                'Разблокировать PRO',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          showCloseButton: true,
          source: 'feature_gate_${feature.name}',
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Виджет для мягкого тизера PRO функции (не блокирует, но показывает PRO badge)
class ProFeatureTeaser extends StatelessWidget {
  final AppFeature feature;
  final Widget child;
  final bool showBadge;
  
  const ProFeatureTeaser({
    super.key,
    required this.feature,
    required this.child,
    this.showBadge = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        final featureGate = FeatureGateService.instance;
        final isAvailable = featureGate.isFeatureAvailable(feature);
        
        if (isAvailable) {
          // PRO пользователь - показываем без badge
          return child;
        }
        
        // FREE пользователь - показываем с PRO badge
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            
            if (showBadge)
              Positioned(
                top: -8,
                right: -8,
                child: _ProBadge(),
              ),
          ],
        );
      },
    );
  }
}

/// Компактный PRO badge
class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPaywall(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'PRO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
  
  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          showCloseButton: true,
          source: 'pro_badge',
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Карточка с информацией о PRO функции
class ProFeatureCard extends StatelessWidget {
  final AppFeature feature;
  final VoidCallback? onUnlock;
  
  const ProFeatureCard({
    super.key,
    required this.feature,
    this.onUnlock,
  });
  
  @override
  Widget build(BuildContext context) {
    final description = FeatureGateService.getFeatureDescription(feature);
    final icon = FeatureGateService.getFeatureIcon(feature);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onUnlock ?? () => _showPaywall(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFFD700).withValues(alpha: 0.1),
                const Color(0xFFFFA500).withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              // Иконка функции
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Описание
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            description,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Нажмите для разблокировки',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Стрелка
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showPaywall(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaywallScreen(
          showCloseButton: true,
          source: 'feature_card_${feature.name}',
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

/// Список PRO функций для отображения в настройках или пейволе
class ProFeaturesList extends StatelessWidget {
  final String? highlightGroup;
  
  const ProFeaturesList({
    super.key,
    this.highlightGroup,
  });
  
  @override
  Widget build(BuildContext context) {
    final groups = FeatureGateService.getProFeatureGroups();
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final groupName = groups.keys.elementAt(index);
        final features = groups[groupName]!;
        final isHighlighted = highlightGroup == groupName;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок группы
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      groupName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isHighlighted ? const Color(0xFFFFD700) : null,
                      ),
                    ),
                    if (isHighlighted) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'НОВОЕ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Список функций в группе
              ...features.map((feature) => _FeatureListTile(
                feature: feature,
                isHighlighted: isHighlighted,
              )),
            ],
          ),
        );
      },
    );
  }
}

/// Элемент списка функции
class _FeatureListTile extends StatelessWidget {
  final AppFeature feature;
  final bool isHighlighted;
  
  const _FeatureListTile({
    required this.feature,
    this.isHighlighted = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final description = FeatureGateService.getFeatureDescription(feature);
    final icon = FeatureGateService.getFeatureIcon(feature);
    final featureGate = FeatureGateService.instance;
    final isAvailable = featureGate.isFeatureAvailable(feature);
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isAvailable 
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isAvailable
            ? Theme.of(context).colorScheme.primary
            : Colors.grey,
        ),
      ),
      title: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          color: isAvailable ? null : Colors.grey,
          decoration: isAvailable ? null : TextDecoration.lineThrough,
        ),
      ),
      trailing: isAvailable
        ? Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          )
        : Icon(
            Icons.lock,
            color: Colors.grey.withValues(alpha: 0.5),
            size: 18,
          ),
      dense: true,
    );
  }
}