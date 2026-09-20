import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/ads_consent.dart';
import '../providers/ads_consent_provider.dart';

Future<void> showPersonalizedAdsPopup(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppLocalizations.of(context).profileMenuPersonalizedAds,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 620),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const Align(
        alignment: Alignment.bottomCenter,
        child: _PersonalizedAdsPopup(),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final slide = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.35),
            end: Offset.zero,
          ).animate(slide),
          child: child,
        ),
      );
    },
  );
}

class _PersonalizedAdsPopup extends ConsumerStatefulWidget {
  const _PersonalizedAdsPopup();

  @override
  ConsumerState<_PersonalizedAdsPopup> createState() =>
      _PersonalizedAdsPopupState();
}

class _PersonalizedAdsPopupState extends ConsumerState<_PersonalizedAdsPopup> {
  bool _adsEnabled = false;
  bool _adjusting = false;
  bool _browsingData = true;
  bool _purchaseHistory = true;
  bool _initialized = false;
  bool _saving = false;

  void _applyConsent(AdsConsent consent) {
    _adsEnabled = consent.adsEnabled;
    _browsingData = consent.browsingData;
    _purchaseHistory = consent.purchaseHistory;
  }

  void _toggleAds([bool? value]) {
    if (_saving) return;
    HapticFeedback.selectionClick();
    final previous = AdsConsent(
      adsEnabled: _adsEnabled,
      browsingData: _browsingData,
      purchaseHistory: _purchaseHistory,
    );
    final next = value ?? !_adsEnabled;
    setState(() {
      _adsEnabled = next;
      _browsingData = next;
      _purchaseHistory = next;
    });
    _persist(
      AdsConsent(adsEnabled: next, browsingData: next, purchaseHistory: next),
      previous: previous,
      closeOnSuccess: false,
    );
  }

  Future<void> _persist(
    AdsConsent consent, {
    AdsConsent? previous,
    bool closeOnSuccess = true,
  }) async {
    setState(() => _saving = true);
    try {
      await ref.read(adsConsentProvider.notifier).save(consent);
      if (mounted) {
        setState(() => _saving = false);
        if (closeOnSuccess) Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          if (previous != null) _applyConsent(previous);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).personalizedAdsSaveError,
            ),
          ),
        );
      }
    }
  }

  void _acceptAll() {
    HapticFeedback.mediumImpact();
    final previous = AdsConsent(
      adsEnabled: _adsEnabled,
      browsingData: _browsingData,
      purchaseHistory: _purchaseHistory,
    );
    setState(() {
      _adsEnabled = true;
      _browsingData = true;
      _purchaseHistory = true;
      _adjusting = false;
    });
    _persist(
      const AdsConsent(
        adsEnabled: true,
        browsingData: true,
        purchaseHistory: true,
      ),
      previous: previous,
    );
  }

  void _openAdjust() {
    HapticFeedback.selectionClick();
    setState(() => _adjusting = !_adjusting);
  }

  void _savePreferences() {
    HapticFeedback.mediumImpact();
    final previous = AdsConsent(
      adsEnabled: _adsEnabled,
      browsingData: _browsingData,
      purchaseHistory: _purchaseHistory,
    );
    final adsEnabled = _browsingData || _purchaseHistory;
    setState(() => _adsEnabled = adsEnabled);
    _persist(
      AdsConsent(
        adsEnabled: adsEnabled,
        browsingData: _browsingData,
        purchaseHistory: _purchaseHistory,
      ),
      previous: previous,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

    ref.listen<AsyncValue<AdsConsent>>(adsConsentProvider, (previous, next) {
      final consent = next.value;
      if (consent != null && !_initialized) {
        _initialized = true;
        setState(() => _applyConsent(consent));
      }
    });

    final consentState = ref.watch(adsConsentProvider);
    if (!_initialized) {
      final consent = consentState.value;
      if (consent != null) {
        _initialized = true;
        _applyConsent(consent);
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 4),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.warmBlack.withValues(alpha: 0.22),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.roseDivider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.blushSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.track_changes_outlined,
                    size: 18,
                    color: AppColors.brandCrimson,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.profileMenuPersonalizedAds,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmBlack,
                    ),
                  ),
                ),
                _CloseButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 18),
            _AdsToggleTile(
              enabled: _adsEnabled,
              onChanged: _toggleAds,
              textTheme: textTheme,
            ),
            const SizedBox(height: 14),
            Text(
              l10n.personalizedAdsBody,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.warmTaupe,
                height: 1.5,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _adjusting
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AdCategoryTile(
                            icon: Icons.travel_explore_rounded,
                            title: l10n.personalizedAdsBrowsingTitle,
                            subtitle: l10n.personalizedAdsBrowsingBody,
                            enabled: _browsingData,
                            onChanged: (value) =>
                                setState(() => _browsingData = value),
                          ),
                          const SizedBox(height: 10),
                          _AdCategoryTile(
                            icon: Icons.receipt_long_rounded,
                            title: l10n.personalizedAdsPurchaseTitle,
                            subtitle: l10n.personalizedAdsPurchaseBody,
                            enabled: _purchaseHistory,
                            onChanged: (value) =>
                                setState(() => _purchaseHistory = value),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: AppColors.brandCrimson,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _saving
                      ? null
                      : (_adjusting ? _savePreferences : _acceptAll),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              _adjusting
                                  ? l10n.personalizedAdsSavePreferences
                                  : l10n.personalizedAdsAcceptAll,
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _openAdjust,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.brandCrimson),
                    ),
                    child: Center(
                      child: Text(
                        _adjusting
                            ? l10n.personalizedAdsHidePreferences
                            : l10n.personalizedAdsAdjustPreferences,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.brandCrimson,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdsToggleTile extends StatelessWidget {
  const _AdsToggleTile({
    required this.enabled,
    required this.onChanged,
    required this.textTheme,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => onChanged(!enabled),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.blushSurface.withValues(alpha: 0.6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled
                  ? AppColors.roseMist.withValues(alpha: 0.4)
                  : AppColors.roseDivider,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.personalizedAdsAllowTitle,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.warmBlack,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AnimatedScale(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                scale: enabled ? 1.06 : 1,
                child: Switch(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdCategoryTile extends StatelessWidget {
  const _AdCategoryTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.petalWhite,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.roseDivider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.blushSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: AppColors.brandCrimson),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warmTaupe,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.blushSurface,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(Icons.close, size: 16, color: AppColors.warmTaupe),
        ),
      ),
    );
  }
}
