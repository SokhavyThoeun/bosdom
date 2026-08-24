import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../notifications/widgets/notification_settings_popup.dart';
import '../widgets/data_privacy_popup.dart';
import '../widgets/marketing_emails_popup.dart';
import '../widgets/personalized_ads_popup.dart';

class _ProfileMenuItem {
  const _ProfileMenuItem(this.icon, this.label, {this.route, this.onTap});

  final IconData icon;
  final String label;
  final String? route;
  final void Function(BuildContext context)? onTap;
}

List<_ProfileMenuItem> _shoppingItems(AppLocalizations l10n) => [
  _ProfileMenuItem(
    Icons.shopping_bag_outlined,
    l10n.profileMenuMyOrders,
    route: 'orders',
  ),
  _ProfileMenuItem(
    Icons.favorite_border,
    l10n.profileMenuCoBuyInvites,
    route: 'coBuying',
  ),
];

List<_ProfileMenuItem> _accountItems(AppLocalizations l10n) => [
  _ProfileMenuItem(
    Icons.location_on_outlined,
    l10n.profileMenuAddressBook,
    route: 'addressBook',
  ),
  _ProfileMenuItem(
    Icons.chat_bubble_outline,
    l10n.profileMenuChat,
    route: 'chatList',
  ),
];

List<_ProfileMenuItem> _settingsItems(AppLocalizations l10n) => [
  _ProfileMenuItem(
    Icons.notifications_none,
    l10n.profileMenuNotifications,
    onTap: showNotificationSettingsPopup,
  ),
  _ProfileMenuItem(
    Icons.credit_card_outlined,
    l10n.profileMenuPaymentCurrency,
    route: 'paymentCurrency',
  ),
  _ProfileMenuItem(
    Icons.language_outlined,
    l10n.profileMenuLanguage,
    route: 'language',
  ),
  _ProfileMenuItem(
    Icons.privacy_tip_outlined,
    l10n.profileMenuDataPrivacy,
    onTap: showDataPrivacyPopup,
  ),
  _ProfileMenuItem(
    Icons.mail_outline,
    l10n.profileMenuMarketingEmails,
    onTap: showMarketingEmailsPopup,
  ),
  _ProfileMenuItem(
    Icons.track_changes_outlined,
    l10n.profileMenuPersonalizedAds,
    onTap: showPersonalizedAdsPopup,
  ),
];

List<_ProfileMenuItem> _supportItems(AppLocalizations l10n) => [
  _ProfileMenuItem(
    Icons.headset_mic_outlined,
    l10n.profileMenuHelpSupport,
    route: 'helpSupport',
  ),
  _ProfileMenuItem(
    Icons.description_outlined,
    l10n.profileMenuTermsConditions,
    route: 'termsConditions',
  ),
  _ProfileMenuItem(
    Icons.shield_outlined,
    l10n.profileMenuPrivacyPolicy,
    route: 'privacyPolicy',
  ),
];

List<_ProfileMenuItem> _aboutItems(AppLocalizations l10n) => [
  _ProfileMenuItem(Icons.info_outline, l10n.profileMenuAbout, route: 'about'),
];

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showComingSoon(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.commonComingSoon(label))));
  }

  void _handleTap(BuildContext context, _ProfileMenuItem item) {
    if (item.onTap != null) {
      item.onTap!(context);
    } else if (item.route != null) {
      context.pushNamed(item.route!);
    } else {
      _showComingSoon(context, item.label);
    }
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
          _ProfileHeader(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  8 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  const _StatsRow(),
                  const SizedBox(height: 24),
                  const _BecomeASellerCard(),
                  const SizedBox(height: 24),
                  _SectionLabel(
                    l10n.profileSectionShopping,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  _MenuGroup(
                    items: _shoppingItems(l10n),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: (item) => _handleTap(context, item),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(
                    l10n.profileSectionAccount,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  _MenuGroup(
                    items: _accountItems(l10n),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: (item) => _handleTap(context, item),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(
                    l10n.profileSectionSettings,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  _MenuGroup(
                    items: _settingsItems(l10n),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: (item) => _handleTap(context, item),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(
                    l10n.profileSectionSupport,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  _MenuGroup(
                    items: _supportItems(l10n),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: (item) => _handleTap(context, item),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel(
                    l10n.profileSectionAbout,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 12),
                  _MenuGroup(
                    items: _aboutItems(l10n),
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: (item) => _handleTap(context, item),
                  ),
                  const SizedBox(height: 28),
                  _LogoutButton(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                    onTap: () => context.goNamed('login'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person,
                  size: 34,
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sokhavy Thoeun',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+855 76 227 5858',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _EditProfileButton(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton({
    required this.colorScheme,
    required this.textTheme,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: colorScheme.onPrimary.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.commonComingSoon(l10n.profileEditProfileLabel)),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_outlined, size: 14, color: colorScheme.onPrimary),
              const SizedBox(width: 6),
              Text(
                l10n.profileEditProfileLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '48',
            label: l10n.profileStatTotalOrders,
            icon: Icons.receipt_long_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '3',
            label: l10n.profileStatActiveOrders,
            icon: Icons.local_shipping_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '12',
            label: l10n.profileStatSavedItems,
            icon: Icons.favorite_rounded,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colorScheme.primary),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _BecomeASellerCard extends StatelessWidget {
  const _BecomeASellerCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.inverseSurface, colorScheme.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -28,
            child: Icon(
              Icons.storefront_rounded,
              size: 140,
              color: colorScheme.onPrimary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.onPrimary.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bolt_rounded,
                        size: 13,
                        color: colorScheme.onPrimary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.profileSellerProgramBadge,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.profileSellerTitle,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.profileSellerSubtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.commonComingSoon(
                            l10n.profileSellerOnboardingLabel,
                          ),
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.profileSellerCta,
                            style: textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(
    this.label, {
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({
    required this.items,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final List<_ProfileMenuItem> items;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final ValueChanged<_ProfileMenuItem> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _MenuTile(
            item: items[i],
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: () => onTap(items[i]),
          ),
          if (i != items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final _ProfileMenuItem item;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          ),
          child: Row(
            children: [
              Icon(item.icon, color: colorScheme.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  item.label,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.profileLogout,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
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
