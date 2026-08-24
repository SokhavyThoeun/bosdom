import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/faq_category.dart';
import '../widgets/call_us_popup.dart';

class _FaqCategory {
  const _FaqCategory(this.id, this.icon, this.label);

  final FaqCategoryId id;
  final IconData icon;
  final String label;
}

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final categories = [
      _FaqCategory(
        FaqCategoryId.gettingStarted,
        Icons.menu_book_rounded,
        l10n.helpSupportCategoryGettingStarted,
      ),
      _FaqCategory(
        FaqCategoryId.ordersPayments,
        Icons.credit_card_rounded,
        l10n.helpSupportCategoryOrdersPayments,
      ),
      _FaqCategory(
        FaqCategoryId.shippingDelivery,
        Icons.local_shipping_rounded,
        l10n.helpSupportCategoryShippingDelivery,
      ),
      _FaqCategory(
        FaqCategoryId.accountVerification,
        Icons.verified_user_rounded,
        l10n.helpSupportCategoryAccountVerification,
      ),
      _FaqCategory(
        FaqCategoryId.returnsDisputes,
        Icons.replay_rounded,
        l10n.helpSupportCategoryReturnsDisputes,
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _HelpSupportHeader(colorScheme: colorScheme, textTheme: textTheme),
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
                  _SearchField(
                    controller: _searchController,
                    hint: l10n.helpSupportSearchHint,
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(l10n.helpSupportCategoriesLabel),
                  const SizedBox(height: 12),
                  for (var i = 0; i < categories.length; i++) ...[
                    _CategoryTile(
                      icon: categories[i].icon,
                      label: categories[i].label,
                      onTap: () => context.pushNamed(
                        'faqCategory',
                        extra: {
                          'id': categories[i].id,
                          'title': categories[i].label,
                        },
                      ),
                    ),
                    if (i != categories.length - 1) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 24),
                  _AssistanceCard(
                    title: l10n.helpSupportAssistanceTitle,
                    body: l10n.helpSupportAssistanceBody,
                    liveChatLabel: l10n.helpSupportLiveChat,
                    callUsLabel: l10n.helpSupportCallUs,
                    onLiveChat: () => context.pushNamed('liveChat'),
                    onCallUs: () => showCallUsPopup(context),
                  ),
                  const SizedBox(height: 16),
                  _ReportIssueButton(
                    label: l10n.helpSupportReportIssue,
                    onTap: () => context.pushNamed('reportIssue'),
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

class _HelpSupportHeader extends StatelessWidget {
  const _HelpSupportHeader({
    required this.colorScheme,
    required this.textTheme,
  });

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
                      : context.goNamed('profile'),
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
                l10n.helpSupportScreenTitle,
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          Icons.search_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.blushSurface,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warmBlack,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssistanceCard extends StatelessWidget {
  const _AssistanceCard({
    required this.title,
    required this.body,
    required this.liveChatLabel,
    required this.callUsLabel,
    required this.onLiveChat,
    required this.onCallUs,
  });

  final String title;
  final String body;
  final String liveChatLabel;
  final String callUsLabel;
  final VoidCallback onLiveChat;
  final VoidCallback onCallUs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warmBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.warmTaupe,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onLiveChat,
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: Text(liveChatLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCallUs,
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: Text(callUsLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportIssueButton extends StatelessWidget {
  const _ReportIssueButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
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
