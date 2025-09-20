import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/remote_config_service.dart';
import '../services/subscription_service.dart';
import '../widgets/ion_character.dart';

enum Plan { lifetime, annual, monthly }

class PricingPack {
  final Plan plan;
  final double price; // full price in USD
  final double? originalPrice; // crossed out, if any
  final String periodLabel; // kept for compatibility
  final bool isBestValue; // highlight annual

  const PricingPack({
    required this.plan,
    required this.price,
    this.originalPrice,
    required this.periodLabel,
    this.isBestValue = false,
  });
}

class PaywallScreen extends StatefulWidget {
  final bool showCloseButton;
  final String source;
  final String? variant;

  const PaywallScreen({
    super.key,
    this.showCloseButton = true,
    this.source = 'unknown',
    this.variant,
  });

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  final RemoteConfigService _rc = RemoteConfigService.instance;
  final AnalyticsService _analytics = AnalyticsService();

  // State
  bool _isLoading = false;
  Plan _selected = Plan.annual;
  bool _trialEnabledSwitch = true;
  bool _showAllFeatures = false;
  bool _dismissLogged = false;

  // offerings (mock for now)
  late Map<Plan, PricingPack> _pricing;

  @override
  void initState() {
    super.initState();
    _trialEnabledSwitch = _rc.trialEnabled;
    _pricing = _mockPricing();
    _analytics.logPaywallShown(
      source: widget.source,
      variant: widget.variant,
    );
  }

  @override
  void dispose() {
    if (!_dismissLogged) {
      _logPaywallDismiss('dispose');
    }
    super.dispose();
  }

  Map<Plan, PricingPack> _mockPricing() {
    return {
      Plan.lifetime: const PricingPack(
        plan: Plan.lifetime,
        price: 49.99,
        periodLabel: 'one-time',
      ),
      Plan.annual: const PricingPack(
        plan: Plan.annual,
        price: 23.99,
        originalPrice: 59.99,
        periodLabel: '/year',
        isBestValue: true,
      ),
      Plan.monthly: const PricingPack(
        plan: Plan.monthly,
        price: 4.99,
        periodLabel: '/month',
      ),
    };
  }

  // ---------- Helpers ----------
  bool get _trialGloballyEnabled => _rc.paywallShowTrial;
  bool get _trialAllowedForSelectedPlan => _selected == Plan.annual; // trial только на годовом
  bool get _showTrialSwitch => _trialGloballyEnabled && _trialAllowedForSelectedPlan;

  String _formatMoney(double v) =>
      v == v.roundToDouble() ? '\$${v.toStringAsFixed(0)}' : '\$${v.toStringAsFixed(2)}';

  String _ctaText(AppLocalizations l10n) {
    final pack = _pricing[_selected]!;
    if (_showTrialSwitch && _trialEnabledSwitch) return l10n.startFreeTrial;

    // без триала — короткая локализованная CTA
    return switch (_selected) {
      Plan.lifetime => l10n.unlockForPrice(_formatMoney(pack.price)),
      Plan.annual => l10n.continueWithPrice(_formatMoney(pack.price)),
      Plan.monthly => l10n.continueWithPrice(_formatMoney(pack.price)),
    };
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (widget.showCloseButton) {
          _logPaywallDismiss('system_back');
        }
        return widget.showCloseButton;
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1214) : const Color(0xFFF8FAFA),
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Header with Ion and benefits
                  Container(
                    height: 240,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Ion Character on the left
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: const IonCharacter(
                              size: 120,
                              mood: IonMood.proud,
                              showGlow: true,
                            ).animate()
                              .scale(duration: 600.ms, curve: Curves.elasticOut)
                              .then()
                              .shimmer(duration: 2000.ms, color: const Color(0xFF8AF5A3).withValues(alpha: 0.2)),
                          ),
                        ),
                        // Benefits on the right
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.unlockPro,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF2D3436),
                                  ),
                                ).animate().fadeIn(delay: 300.ms),
                                const SizedBox(height: 8),
                                _buildQuickBenefit(Icons.sports_score, l10n.sportRecoveryProtocols, isDark),
                                const SizedBox(height: 4),
                                _buildQuickBenefit(Icons.local_bar, l10n.alcoholProtocols, isDark),
                                const SizedBox(height: 4),
                                _buildQuickBenefit(Icons.local_drink, l10n.allDrinksAndSupplements, isDark),
                                const SizedBox(height: 4),
                                _buildQuickBenefit(Icons.show_chart, l10n.weeklyReports, isDark),
                                const SizedBox(height: 4),
                                _buildQuickBenefit(Icons.notifications_active, l10n.smartReminders, isDark),
                              ].animate(interval: 100.ms).fadeIn(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pricing & CTA
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0B0E10) : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPricingOptions(isDark, l10n),
                            const SizedBox(height: 16),
                            if (_showTrialSwitch) _buildTrialToggle(isDark, l10n),
                            const SizedBox(height: 16),
                            _buildCtaButton(isDark, l10n),
                            const SizedBox(height: 8),
                            _buildAutoRenewNote(isDark, l10n),
                            const SizedBox(height: 24),
                            _buildPoliciesAndRestore(isDark, l10n),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Close
              if (widget.showCloseButton)
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      _logPaywallDismiss('close_button');
                      Navigator.of(context).pop();
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white12 : Colors.white.withValues(alpha: 0.9)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 20, color: isDark ? Colors.white : const Color(0xFF2D3436)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickBenefit(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.cyan.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: Colors.cyan),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Widgets ----------
  Widget _buildPricingOptions(bool isDark, AppLocalizations l10n) {
    final tilesBg = isDark ? const Color(0x1412FFFF) : const Color(0xFFF3F8F8);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: tilesBg, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _pricingTile(_pricing[Plan.lifetime]!, isDark, l10n),
          const SizedBox(height: 8),
          _pricingTile(_pricing[Plan.annual]!, isDark, l10n),
          const SizedBox(height: 8),
          _pricingTile(_pricing[Plan.monthly]!, isDark, l10n),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _pricingTile(PricingPack pack, bool isDark, AppLocalizations l10n) {
    final isSelected = _selected == pack.plan;
    final highlight = pack.isBestValue;

    final bg = isSelected
        ? (isDark ? const Color(0xFF0E2330) : Colors.cyan.shade50)
        : (isDark ? const Color(0xFF12161A) : Colors.white);

    final borderColor = isSelected
        ? (isDark ? const Color(0xFF2FB8E9) : Colors.cyan.shade400)
        : (highlight ? (isDark ? const Color(0xFF1E7896) : Colors.cyan.shade200)
                     : (isDark ? Colors.white10 : Colors.grey.shade200));

    final textMain = isDark ? Colors.white : const Color(0xFF2D3436);

    final original = pack.originalPrice != null ? _formatMoney(pack.originalPrice!) : null;
    final price = _formatMoney(pack.price);

    final isAnnual = pack.plan == Plan.annual;
    final perMonthLabel = isAnnual ? l10n.approximatelyPerMonth(_formatMoney(pack.price / 12)) : null;

    // FIXED: Всегда используем локализацию, не Remote Config
    final title = switch (pack.plan) {
      Plan.lifetime => l10n.lifetimeAccess,
      Plan.annual  => l10n.bestValueAnnual,
      Plan.monthly => l10n.monthly,
    };

    // локализованный период
    final periodText = switch (pack.plan) {
      Plan.lifetime => l10n.oneTime,   // "единоразово"
      Plan.annual   => l10n.perYear,   // "/год"
      Plan.monthly  => l10n.perMonth,  // "/месяц"
    };

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (_selected != pack.plan) {
          _analytics.logPaywallPlanSelected(
            plan: pack.plan.name,
            source: widget.source,
            variant: widget.variant,
          );
        }
        setState(() => _selected = pack.plan);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
          gradient: (isAnnual && isSelected)
              ? LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0E2330), const Color(0xFF0B1720)]
                      : [Colors.cyan.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (isDark ? Colors.cyanAccent.withValues(alpha: 0.08)
                                   : Colors.cyan.withValues(alpha: 0.15)),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                // radio
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.cyan : (isDark ? Colors.white30 : Colors.grey.shade400),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.cyan),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textMain)),
                      const SizedBox(height: 4),

                      // одна строка с ценой, периодом, зачёркнутой ценой и ≈/mo
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.grey.shade600),
                          children: [
                            TextSpan(
                              text: price,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? (isDark ? Colors.cyanAccent : Colors.cyan.shade700) : textMain,
                              ),
                            ),
                            const TextSpan(text: ' '),
                            TextSpan(text: periodText),
                            if (original != null) ...[
                              const TextSpan(text: '  '),
                              TextSpan(
                                text: original,
                                style: TextStyle(
                                  color: isDark ? Colors.white38 : Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                            if (perMonthLabel != null) ...[
                              const TextSpan(text: '   •   '),
                              TextSpan(text: perMonthLabel),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // badge (без дубля "Best value")
            if (highlight)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.pink.shade400, Colors.pink.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.pink.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Text(
                    original != null
                        ? l10n.percentOff(_discountPercent(pack.price, pack.originalPrice!).round())
                        : l10n.bestValue,
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _discountPercent(double price, double original) => (1 - price / original) * 100;

  void _logPaywallDismiss(String reason) {
    if (_dismissLogged) {
      return;
    }
    _dismissLogged = true;
    _analytics.logPaywallDismissed(
      source: widget.source,
      reason: reason,
    );
  }

  Widget _buildTrialToggle(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF12161A) : const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.enableFreeTrial,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : const Color(0xFF2D3436)),
            ),
          ),
          CupertinoSwitch(
            value: _trialEnabledSwitch,
            activeTrackColor: Colors.cyan,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              setState(() => _trialEnabledSwitch = v);
              _analytics.logPaywallTrialToggle(
                source: widget.source,
                enabled: v,
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 380.ms);
  }

  Widget _buildCtaButton(bool isDark, AppLocalizations l10n) {
    final disabled = _isLoading;
    return GestureDetector(
      onTap: disabled ? null : _handlePurchase,
      child: AnimatedOpacity(
        duration: 200.ms,
        opacity: disabled ? 0.6 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.cyan,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.cyan.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                    _ctaText(l10n),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 450.ms).slideY();
  }

  Widget _buildAutoRenewNote(bool isDark, AppLocalizations l10n) {
    final color = isDark ? Colors.white70 : Colors.grey.shade700;
    
    // Показываем разный текст в зависимости от триала
    final text = (_showTrialSwitch && _trialEnabledSwitch) 
        ? l10n.noChargeToday 
        : l10n.cancelAnytime;
    
    return Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: color, height: 1.3));
  }

  Widget _buildFeatures(bool isDark, AppLocalizations l10n) {
    final baseColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final subColor = isDark ? Colors.white70 : Colors.grey.shade600;

    final all = <Map<String, dynamic>>[
      {'icon': Icons.notifications_active, 'title': l10n.smartReminders, 'desc': l10n.smartRemindersDesc},
      {'icon': Icons.analytics, 'title': l10n.weeklyReports, 'desc': l10n.weeklyReportsDesc},
      {'icon': Icons.health_and_safety, 'title': l10n.healthIntegrations, 'desc': l10n.healthIntegrationsDesc},
      {'icon': Icons.local_bar, 'title': l10n.alcoholProtocols, 'desc': l10n.alcoholProtocolsDesc},
      {'icon': Icons.sync, 'title': l10n.fullSync, 'desc': l10n.fullSyncDesc},
      {'icon': Icons.tune, 'title': l10n.personalCalibrations, 'desc': l10n.personalCalibrationsDesc},
    ];

    final visible = _showAllFeatures ? all : all.take(4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        ...visible.map((f) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Colors.cyan.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                  child: Icon(f['icon'] as IconData, color: Colors.cyan.shade600, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f['title'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor)),
                      const SizedBox(height: 2),
                      Text(f['desc'] as String, style: TextStyle(fontSize: 12, color: subColor, height: 1.3)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        TextButton(
          onPressed: () => setState(() => _showAllFeatures = !_showAllFeatures),
          child: Text(_showAllFeatures ? l10n.showLess : l10n.showAllFeatures,
              style: TextStyle(fontSize: 13, color: isDark ? Colors.cyanAccent : Colors.cyan.shade700)),
        ),
      ],
    );
  }

  Widget _buildPoliciesAndRestore(bool isDark, AppLocalizations l10n) {
    final linkStyle = TextStyle(
      fontSize: 11,
      color: isDark ? Colors.white70 : Colors.grey.shade700,
      decoration: TextDecoration.underline,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: _openPrivacy, child: Text(l10n.privacyPolicy, style: linkStyle)),
            Text(' • ', style: TextStyle(color: isDark ? Colors.white24 : Colors.grey.shade400)),
            TextButton(onPressed: _openTerms, child: Text(l10n.termsOfUse, style: linkStyle)),
          ],
        ),
        TextButton(
          onPressed: _isLoading ? null : _handleRestore,
          child: Text(
            l10n.restorePurchases,
            style: TextStyle(
              fontSize: 12,
              color: _isLoading ? (isDark ? Colors.white38 : Colors.grey) : (isDark ? Colors.cyanAccent : Colors.cyan.shade700),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Actions ----------
  Future<void> _handlePurchase() async {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    final bool trialEnabledForAnalytics = _showTrialSwitch && _trialEnabledSwitch;

    try {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);

      // ID продукта по плану
      String productId;
      switch (_selected) {
        case Plan.lifetime:
          productId = 'hydracoach_pro_yearly'; // используем годовую для lifetime
          break;
        case Plan.annual:
          productId = 'hydracoach_pro_yearly';
          break;
        case Plan.monthly:
          productId = 'hydracoach_pro_monthly';
          break;
      }

      print('🛍️ Initiating purchase for plan: ${_selected.name}');
      print('📦 Product ID: $productId');
      _analytics.logSubscriptionPurchaseAttempt(
        product: _selected.name,
        source: widget.source,
        trialEnabled: trialEnabledForAnalytics,
      );

      bool success = false;

      if (kDebugMode) {
        // В debug режиме показываем диалог выбора: мок или реальная покупка
        final mockPurchase = await showDialog<String>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Test Purchase'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose purchase type for testing:'),
                const SizedBox(height: 8),
                Consumer<SubscriptionProvider>(
                  builder: (context, subscription, child) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: subscription.isPro ? Colors.green.shade50 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: subscription.isPro ? Colors.green : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          subscription.isPro ? Icons.verified : Icons.lock,
                          color: subscription.isPro ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Current status: ${subscription.isPro ? "PRO" : "FREE"}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: subscription.isPro ? Colors.green.shade700 : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, 'mock_success'),
                child: const Text('Mock Purchase (Success)'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'mock_clear'),
                child: const Text('Clear PRO Status'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'real'),
                child: const Text('Real Purchase'),
              ),
            ],
          ),
        );

        if (mockPurchase == 'mock_success') {
          // Мок покупка - всегда успешная
          print('🎭 Mock purchase initiated - simulating success');
          await Future.delayed(const Duration(seconds: 1)); // Имитируем задержку
          success = true;
          // Устанавливаем Pro статус в subscription provider
          await subscriptionProvider.setMockProStatus(true);
        } else if (mockPurchase == 'mock_clear') {
          // Сброс PRO статуса
          print('🎭 Clearing PRO status');
          await subscriptionProvider.clearMockProStatus();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PRO status cleared'),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return; // Выходим из метода
        } else {
          // Реальная покупка через Google Play
          success = await subscriptionProvider.purchaseSubscription(productId);
        }
      } else {
        // В релизе всегда реальная покупка
        success = await subscriptionProvider.purchaseSubscription(productId);
      }

      _analytics.logSubscriptionPurchaseResult(
        product: _selected.name,
        source: widget.source,
        success: success,
        trialEnabled: trialEnabledForAnalytics,
      );

      if (!mounted) return;

      if (success) {
        await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                child: Icon(Icons.check_circle, size: 48, color: Colors.green.shade500),
              ),
              const SizedBox(height: 20),
              Text(l10n.welcomeToPro, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(l10n.allFeaturesUnlocked, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.testMode,
                            style: TextStyle(fontSize: 12, color: Colors.orange.shade700, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(l10n.proStatusNote, style: TextStyle(fontSize: 11, color: Colors.orange.shade600)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logPaywallDismiss('purchase_success');
                Navigator.of(context).pop(true);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: Text(l10n.startUsingPro,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            )
          ],
        ),
        );

        print('✅ PRO activated successfully!');
      } else {
        // Покупка не удалась
        if (kDebugMode) {
          print('❌ Purchase was not successful');
        }
      }
    } catch (e) {
      if (!mounted) return;
      print('❌ Purchase error: $e');
      _analytics.logSubscriptionPurchaseResult(
        product: _selected.name,
        source: widget.source,
        success: false,
        trialEnabled: trialEnabledForAnalytics,
        error: e.toString(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.purchaseFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestore() async {
    final l10n = AppLocalizations.of(context);
    if (_isLoading) return;
    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);

    try {
      final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      print('🔄 Attempting to restore purchases...');
      _analytics.logSubscriptionRestoreAttempt(source: widget.source);
      final restored = await subscriptionProvider.restorePurchases();

      if (!mounted) return;

      if (restored) {
        print('✅ Purchases restored successfully!');
        _analytics.logSubscriptionRestoreResult(
          source: widget.source,
          success: true,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.proSubscriptionRestored),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _logPaywallDismiss('restore_success');
        Navigator.of(context).pop(true);
      } else {
        print('ℹ️ No purchases to restore');
        _analytics.logSubscriptionRestoreResult(
          source: widget.source,
          success: false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noPurchasesToRestore),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      print('❌ Restore error: $e');
      _analytics.logSubscriptionRestoreResult(
        source: widget.source,
        success: false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.restoreFailed(e.toString())),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openPrivacy() {
    // TODO: open privacy URL
    print('📄 Opening Privacy Policy...');
  }

  void _openTerms() {
    // TODO: open terms URL
    print('📄 Opening Terms of Use...');
  }
}