import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

Future<void> showNotificationSettingsPopup(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: AppLocalizations.of(context).notificationsScreenTitle,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 620),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const Align(
        alignment: Alignment.bottomCenter,
        child: _NotificationSettingsPopup(),
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

class _NotificationSettingsPopup extends StatefulWidget {
  const _NotificationSettingsPopup();

  @override
  State<_NotificationSettingsPopup> createState() =>
      _NotificationSettingsPopupState();
}

class _NotificationSettingsPopupState
    extends State<_NotificationSettingsPopup> {
  bool _pushEnabled = true;

  void _toggle([bool? value]) {
    HapticFeedback.selectionClick();
    setState(() => _pushEnabled = value ?? !_pushEnabled);
  }

  @override
  Widget build(BuildContext context) {
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.blushSurface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_rounded,
                    size: 18,
                    color: AppColors.brandCrimson,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.notificationsScreenTitle,
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
            _PushNotificationTile(
              enabled: _pushEnabled,
              onChanged: _toggle,
              textTheme: textTheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _PushNotificationTile extends StatelessWidget {
  const _PushNotificationTile({
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notificationsPushTitle,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.warmBlack,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.notificationsPushBody,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warmTaupe,
                        height: 1.4,
                      ),
                    ),
                  ],
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
