import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../providers/chat_policy_provider.dart';

/// Wraps a chat screen; blocks it behind a one-time ToS/liability
/// acceptance gate until [chatPolicyProvider] reports the user has agreed.
class ChatPolicyGate extends ConsumerWidget {
  const ChatPolicyGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policyAsync = ref.watch(chatPolicyProvider);
    final l10n = AppLocalizations.of(context);

    return policyAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(child: Text(l10n.chatPolicyLoadError(error.toString()))),
      ),
      data: (accepted) => accepted ? child : const _ChatPolicyScreen(),
    );
  }
}

class _ChatPolicyScreen extends ConsumerStatefulWidget {
  const _ChatPolicyScreen();

  @override
  ConsumerState<_ChatPolicyScreen> createState() => _ChatPolicyScreenState();
}

class _ChatPolicyScreenState extends ConsumerState<_ChatPolicyScreen> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  Text(
                    l10n.chatPolicyIntro,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmTaupe,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _PolicyPoint(
                    icon: Icons.verified_user_outlined,
                    title: l10n.chatPolicySecurePayTitle,
                    body: l10n.chatPolicySecurePayBody,
                  ),
                  const SizedBox(height: 14),
                  _PolicyPoint(
                    icon: Icons.flag_outlined,
                    title: l10n.chatPolicyFlaggedTitle,
                    body: l10n.chatPolicyFlaggedBody,
                  ),
                  const SizedBox(height: 14),
                  _PolicyPoint(
                    icon: Icons.gavel_outlined,
                    title: l10n.chatPolicyLiableTitle,
                    body: l10n.chatPolicyLiableBody,
                  ),
                  const SizedBox(height: 24),
                  _AgreementCheckbox(
                    value: _agreed,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() => _agreed = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  _ContinueButton(
                    enabled: _agreed,
                    onTap: () => ref.read(chatPolicyProvider.notifier).accept(),
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

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(color: colorScheme.primary),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          MediaQuery.of(context).padding.top + 10,
          24,
          14,
        ),
        child: SizedBox(
          height: 68,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.canPop()
                      ? context.pop()
                      : context.goNamed('profile'),
                  borderRadius: BorderRadius.circular(8),
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
              Text(
                l10n.chatPolicyHeaderTitle,
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

class _PolicyPoint extends StatelessWidget {
  const _PolicyPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.roseDivider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.blushSurface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: AppColors.brandCrimson),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 3),
                Text(
                  body,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.warmTaupe,
                    height: 1.35,
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

class _AgreementCheckbox extends StatelessWidget {
  const _AgreementCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onChanged(!value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: value
                ? AppColors.blushSurface.withValues(alpha: 0.6)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: value ? AppColors.brandCrimson : AppColors.roseDivider,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: value,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.brandCrimson,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).chatPolicyAgreementText,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.warmBlack,
                    height: 1.4,
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

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: enabled ? AppColors.brandCrimson : AppColors.roseDivider,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context).chatPolicyContinueButton,
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
