import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

class _Feature {
  const _Feature(this.icon, this.title, this.body);

  final IconData icon;
  final String title;
  final String body;
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    final features = [
      _Feature(
        Icons.verified_outlined,
        l10n.aboutFeatureSampleTestingTitle,
        l10n.aboutFeatureSampleTestingBody,
      ),
      _Feature(
        Icons.groups_outlined,
        l10n.aboutFeatureCoBuyTitle,
        l10n.aboutFeatureCoBuyBody,
      ),
      _Feature(
        Icons.shield_outlined,
        l10n.aboutFeatureEscrowTitle,
        l10n.aboutFeatureEscrowBody,
      ),
      _Feature(
        Icons.chat_bubble_outline,
        l10n.aboutFeatureChatTitle,
        l10n.aboutFeatureChatBody,
      ),
    ];

    final offerItems = [
      l10n.aboutOfferItem1,
      l10n.aboutOfferItem2,
      l10n.aboutOfferItem3,
      l10n.aboutOfferItem4,
      l10n.aboutOfferItem5,
      l10n.aboutOfferItem6,
    ];

    final values = [
      l10n.aboutValueTrustTitle,
      l10n.aboutValueRetailerFirstTitle,
      l10n.aboutValueInnovationTitle,
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _AboutHeader(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  24,
                  20,
                  8 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _BrandBlock(colorScheme: colorScheme, textTheme: textTheme),
                  const SizedBox(height: 24),
                  _MissionCard(colorScheme: colorScheme, textTheme: textTheme),
                  const SizedBox(height: 24),
                  _SectionHeading(l10n.aboutWhyChooseTitle, textTheme: textTheme),
                  const SizedBox(height: 12),
                  _FeatureGrid(
                    features: features,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeading(l10n.aboutOfferTitle, textTheme: textTheme),
                  const SizedBox(height: 12),
                  _OfferCard(
                    items: offerItems,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeading(l10n.aboutCompanyInfoTitle, textTheme: textTheme),
                  const SizedBox(height: 12),
                  _CompanyInfoCard(colorScheme: colorScheme, textTheme: textTheme),
                  const SizedBox(height: 24),
                  _StoryCard(colorScheme: colorScheme, textTheme: textTheme),
                  const SizedBox(height: 24),
                  _StatsBanner(colorScheme: colorScheme, textTheme: textTheme),
                  const SizedBox(height: 24),
                  _SectionHeading(l10n.aboutValuesTitle, textTheme: textTheme),
                  const SizedBox(height: 12),
                  _ValuesList(
                    values: values,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: Text(
                      l10n.aboutFooterCopyright,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warmTaupe,
                      ),
                    ),
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

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
                l10n.aboutScreenTitle,
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

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.30),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const _GlowingLogo(size: 84),
        ),
        const SizedBox(height: 16),
        Text(
          'Bosdom',
          style: textTheme.headlineMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.aboutAppTagline,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.warmTaupe,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.aboutVersionLabel('1.0.0'),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

/// Mirrors the splash screen's logo glow exactly: a soft radial white
/// halo the same size as the badge, with the logo mark at 85% of it.
class _GlowingLogo extends StatelessWidget {
  const _GlowingLogo({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white.withValues(alpha: 0.02),
                  Colors.white.withValues(alpha: 0),
                ],
                stops: const [0, 0.3, 0.6, 1],
              ),
            ),
          ),
          SizedBox(
            width: size * 0.85,
            height: size * 0.85,
            child: Image.asset('assets/images/bosdom-logo-white.png'),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aboutMissionTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.aboutMissionBody,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.warmTaupe,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.label, {required this.textTheme});

  final String label;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.titleMedium?.copyWith(
        color: AppColors.brandCrimson,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({
    required this.features,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<_Feature> features;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < features.length; i += 2) ...[
          if (i != 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _FeatureCard(
                    feature: features[i],
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < features.length
                      ? _FeatureCard(
                          feature: features[i + 1],
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.colorScheme,
    required this.textTheme,
  });

  final _Feature feature;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blushSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.roseMist.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(feature.icon, size: 19, color: colorScheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            feature.title,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warmBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            feature.body,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.warmTaupe,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({
    required this.items,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<String> items;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    items[i],
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.warmBlack,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (i != items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _CompanyInfoCard extends StatelessWidget {
  const _CompanyInfoCard({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final rows = [
      (Icons.location_on_outlined, l10n.aboutCompanyHeadquartersLabel, l10n.aboutCompanyHeadquartersValue),
      (Icons.mail_outline_rounded, l10n.aboutCompanyEmailLabel, l10n.aboutCompanyEmailValue),
      (Icons.public_outlined, l10n.aboutCompanyWebsiteLabel, l10n.aboutCompanyWebsiteValue),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(rows[i].$1, size: 18, color: colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rows[i].$2,
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rows[i].$3,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.warmBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i != rows.length - 1) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blushSurface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.roseMist.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.aboutStoryTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warmBlack,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.aboutStoryBody,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.warmTaupe,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsBanner extends StatelessWidget {
  const _StatsBanner({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final stats = [
      ('1K+', l10n.aboutStatRetailers),
      ('500+', l10n.aboutStatSuppliers),
      ('99.5%', l10n.aboutStatSuccessRate),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.inverseSurface],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.30),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < stats.length; i++) ...[
            Expanded(
              child: Column(
                children: [
                  Text(
                    stats[i].$1,
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats[i].$2,
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (i != stats.length - 1)
              SizedBox(
                height: 36,
                child: VerticalDivider(
                  color: colorScheme.onPrimary.withValues(alpha: 0.25),
                  thickness: 1,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ValuesList extends StatelessWidget {
  const _ValuesList({
    required this.values,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<String> values;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    values[i],
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warmBlack,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (i != values.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
