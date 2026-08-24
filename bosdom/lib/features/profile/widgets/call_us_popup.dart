import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

const _kSupportPhoneNumber = '+85523456789';

Future<void> showCallUsPopup(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppLocalizations.of(context).helpSupportCallUs,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 620),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const Align(
        alignment: Alignment.bottomCenter,
        child: _CallUsPopup(),
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

class _CallUsPopup extends StatelessWidget {
  const _CallUsPopup();

  Future<void> _callNow(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final uri = Uri(scheme: 'tel', path: _kSupportPhoneNumber);
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.callUsPopupLaunchError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final l10n = AppLocalizations.of(context);

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
                Expanded(
                  child: Text(
                    l10n.helpSupportCallUs,
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warmBlack,
                    ),
                  ),
                ),
                _CloseButton(onTap: () => Navigator.of(context).pop()),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              l10n.callUsPopupBody,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.warmTaupe,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _HoursBanner(textTheme: textTheme, label: l10n.callUsPopupHours),
            const SizedBox(height: 14),
            _PhoneCard(
              textTheme: textTheme,
              colorScheme: colorScheme,
              supportLabel: l10n.callUsPopupSupportLabel,
              phoneNumber: l10n.callUsPopupPhoneNumber,
            ),
            const SizedBox(height: 18),
            _CallNowButton(
              textTheme: textTheme,
              colorScheme: colorScheme,
              label: l10n.callUsPopupCallNow,
              onTap: () => _callNow(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoursBanner extends StatelessWidget {
  const _HoursBanner({required this.textTheme, required this.label});

  final TextTheme textTheme;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blushSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.access_time_rounded,
            size: 17,
            color: AppColors.brandCrimson,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.brandCrimson,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneCard extends StatelessWidget {
  const _PhoneCard({
    required this.textTheme,
    required this.colorScheme,
    required this.supportLabel,
    required this.phoneNumber,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final String supportLabel;
  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.blushSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.phone_outlined,
              size: 18,
              color: AppColors.brandCrimson,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supportLabel,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.warmTaupe,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  phoneNumber,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandCrimson,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CallNowButton extends StatelessWidget {
  const _CallNowButton({
    required this.textTheme,
    required this.colorScheme,
    required this.label,
    required this.onTap,
  });

  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.brandCrimson,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.call_rounded, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: textTheme.labelLarge?.copyWith(
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
