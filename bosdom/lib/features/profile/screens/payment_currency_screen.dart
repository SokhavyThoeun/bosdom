import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

enum _CurrencyCode { usd, khr }

extension on _CurrencyCode {
  String name(AppLocalizations l10n) =>
      this == _CurrencyCode.usd ? l10n.currencyUsdName : l10n.currencyKhrName;
  String get symbol => this == _CurrencyCode.usd ? r'$' : '៛';
  String get rateLine => this == _CurrencyCode.usd
      ? r'$1.00 = ៛4,100'
      : '៛4,100 = \$1.00';
}

class PaymentCurrencyScreen extends StatefulWidget {
  const PaymentCurrencyScreen({super.key});

  @override
  State<PaymentCurrencyScreen> createState() => _PaymentCurrencyScreenState();
}

class _PaymentCurrencyScreenState extends State<PaymentCurrencyScreen> {
  _CurrencyCode _selected = _CurrencyCode.usd;
  bool _showBoth = true;
  bool _refreshing = false;
  bool _saving = false;
  bool _justSaved = false;
  String _lastUpdated = 'Aug 8, 2026';

  void _selectCurrency(_CurrencyCode code) {
    if (code == _selected) return;
    HapticFeedback.selectionClick();
    setState(() => _selected = code);
  }

  Future<void> _refreshRate() async {
    if (_refreshing) return;
    HapticFeedback.lightImpact();
    setState(() => _refreshing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _refreshing = false;
      _lastUpdated = 'Just now';
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    HapticFeedback.mediumImpact();
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() {
      _saving = false;
      _justSaved = true;
    });
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.currencySavedSnackbar)),
    );
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    setState(() => _justSaved = false);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _CurrencyHeader(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  8 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  Text(
                    l10n.currencyScreenIntro,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmTaupe,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(l10n.currencySectionSelect),
                  const SizedBox(height: 12),
                  _CurrencyCard(
                    code: _CurrencyCode.usd,
                    selected: _selected == _CurrencyCode.usd,
                    onTap: () => _selectCurrency(_CurrencyCode.usd),
                  ),
                  const SizedBox(height: 12),
                  _CurrencyCard(
                    code: _CurrencyCode.khr,
                    selected: _selected == _CurrencyCode.khr,
                    onTap: () => _selectCurrency(_CurrencyCode.khr),
                  ),
                  const SizedBox(height: 24),
                  _ExchangeRateCard(
                    selected: _selected,
                    refreshing: _refreshing,
                    lastUpdated: _lastUpdated,
                    onRefresh: _refreshRate,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(l10n.currencySectionDisplaySettings),
                  const SizedBox(height: 12),
                  _DisplayToggleTile(
                    enabled: _showBoth,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _showBoth = value);
                    },
                  ),
                  const SizedBox(height: 28),
                  _SaveButton(
                    saving: _saving,
                    saved: _justSaved,
                    onTap: _save,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyHeader extends StatelessWidget {
  const _CurrencyHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 16,
          24,
          20,
        ),
        child: SizedBox(
          height: 96,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('marketplace'),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.commonBack,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                l10n.currencyScreenTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.warmTaupe,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  const _CurrencyCard({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final _CurrencyCode code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.blushSurface.withValues(alpha: 0.55)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected ? AppColors.brandCrimson : AppColors.roseDivider,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blushSurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  code.symbol,
                  style: textTheme.titleMedium?.copyWith(
                    color: AppColors.brandCrimson,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      code.name(l10n),
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      code.rateLine,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warmTaupe,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 26,
                height: 26,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  scale: selected ? 1 : 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.brandCrimson,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExchangeRateCard extends StatelessWidget {
  const _ExchangeRateCard({
    required this.selected,
    required this.refreshing,
    required this.lastUpdated,
    required this.onRefresh,
  });

  final _CurrencyCode selected;
  final bool refreshing;
  final String lastUpdated;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blushSurface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.roseDivider.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.currencyExchangeRateLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.brandCrimson,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _RefreshChip(refreshing: refreshing, onTap: onRefresh),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.15),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              selected.rateLine,
              key: ValueKey(selected),
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.warmBlack,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Exchange rates are updated daily. Final conversion rates are '
            'applied at the time of payment.',
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.warmTaupe,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.roseDivider.withValues(alpha: 0.7)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Last updated: $lastUpdated',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.warmTaupe,
                ),
              ),
              const Spacer(),
              const _LiveDot(),
              const SizedBox(width: 6),
              Text(
                'Active',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.trustGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RefreshChip extends StatelessWidget {
  const _RefreshChip({required this.refreshing, required this.onTap});

  final bool refreshing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: refreshing ? 1 : 0),
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) => Transform.rotate(
                  angle: value * 6.28319,
                  child: child,
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  size: 15,
                  color: AppColors.brandCrimson,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Daily Update',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.brandCrimson,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.4,
        end: 1,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppColors.trustGreen,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _DisplayToggleTile extends StatelessWidget {
  const _DisplayToggleTile({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onChanged(!enabled),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.roseDivider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Show prices in both currencies',
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warmBlack,
                  ),
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.brandCrimson,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.roseDivider,
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.saving,
    required this.saved,
    required this.onTap,
  });

  final bool saving;
  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final backgroundColor = saved ? AppColors.trustGreen : AppColors.brandCrimson;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: saving ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 52,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: saving
                ? const SizedBox(
                    key: ValueKey('loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    key: ValueKey(saved),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (saved) ...[
                        const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        saved ? 'Saved' : 'Save Changes',
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
