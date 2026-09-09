import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

enum _BlockStyle { paragraph, bullet, lead }

class _PrivacyBlock {
  const _PrivacyBlock(this.text, this.style);

  final String text;
  final _BlockStyle style;
}

class _PrivacySection {
  const _PrivacySection(this.title, this.blocks);

  final String title;
  final List<_PrivacyBlock> blocks;
}

List<_PrivacySection> _sections(AppLocalizations l10n) => [
  _PrivacySection(l10n.privacyPolicySection1Title, [
    _PrivacyBlock(l10n.privacyPolicySection1Point1, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection1Point2, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point4, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point5, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point6, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection1Point7, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point8, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point9, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point10, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection1Point11, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point12, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point13, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection1Point14, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point15, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point16, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection1Point17, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point18, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point19, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection1Point20, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point21, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point22, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point23, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection1Point24, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection1Point25, _BlockStyle.bullet),
  ]),
  _PrivacySection(l10n.privacyPolicySection2Title, [
    _PrivacyBlock(l10n.privacyPolicySection2Point1, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection2Point2, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection2Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point4, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point5, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point6, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point7, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection2Point8, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point9, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point10, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point11, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point12, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection2Point13, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point14, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point15, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point16, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point17, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection2Point18, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point19, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection2Point20, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point21, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection2Point22, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection2Point23, _BlockStyle.bullet),
  ]),
  _PrivacySection(l10n.privacyPolicySection3Title, [
    _PrivacyBlock(l10n.privacyPolicySection3Point1, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection3Point2, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection3Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection3Point4, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection3Point5, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection3Point6, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection3Point7, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection3Point8, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection3Point9, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection3Point10, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection3Point11, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection3Point12, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection3Point13, _BlockStyle.lead),
    _PrivacyBlock(l10n.privacyPolicySection3Point14, _BlockStyle.bullet),
  ]),
  _PrivacySection(l10n.privacyPolicySection4Title, [
    _PrivacyBlock(l10n.privacyPolicySection4Point1, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection4Point2, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection4Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection4Point4, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection4Point5, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection4Point6, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection4Point7, _BlockStyle.paragraph),
  ]),
  _PrivacySection(l10n.privacyPolicySection5Title, [
    _PrivacyBlock(l10n.privacyPolicySection5Point1, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection5Point2, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection5Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection5Point4, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection5Point5, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection5Point6, _BlockStyle.paragraph),
  ]),
  _PrivacySection(l10n.privacyPolicySection6Title, [
    _PrivacyBlock(l10n.privacyPolicySection6Point1, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection6Point2, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection6Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection6Point4, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection6Point5, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection6Point6, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection6Point7, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection6Point8, _BlockStyle.paragraph),
  ]),
  _PrivacySection(l10n.privacyPolicySection7Title, [
    _PrivacyBlock(l10n.privacyPolicySection7Point1, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection7Point2, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection7Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection7Point4, _BlockStyle.bullet),
  ]),
  _PrivacySection(l10n.privacyPolicySection8Title, [
    _PrivacyBlock(l10n.privacyPolicySection8Point1, _BlockStyle.paragraph),
  ]),
  _PrivacySection(l10n.privacyPolicySection9Title, [
    _PrivacyBlock(l10n.privacyPolicySection9Point1, _BlockStyle.paragraph),
    _PrivacyBlock(l10n.privacyPolicySection9Point2, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection9Point3, _BlockStyle.bullet),
    _PrivacyBlock(l10n.privacyPolicySection9Point4, _BlockStyle.bullet),
  ]),
];

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final sections = _sections(l10n);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Column(
        children: [
          _PrivacyHeader(colorScheme: colorScheme, textTheme: textTheme),
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
                    l10n.privacyPolicyEffectiveDate,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.warmTaupe,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  for (final section in sections) ...[
                    _SectionCard(section: section, textTheme: textTheme),
                    const SizedBox(height: 14),
                  ],
                  _ContactCard(textTheme: textTheme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyHeader extends StatelessWidget {
  const _PrivacyHeader({required this.colorScheme, required this.textTheme});

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
                  child: Icon(
                    Icons.arrow_back,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
              Text(
                l10n.privacyPolicyScreenTitle,
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.textTheme});

  final _PrivacySection section;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            section.title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warmBlack,
            ),
          ),
          const SizedBox(height: 10),
          for (final block in section.blocks)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PrivacyBlockView(block: block, textTheme: textTheme),
            ),
        ],
      ),
    );
  }
}

class _PrivacyBlockView extends StatelessWidget {
  const _PrivacyBlockView({required this.block, required this.textTheme});

  final _PrivacyBlock block;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = textTheme.bodySmall?.copyWith(
      color: AppColors.warmTaupe,
      height: 1.5,
    );

    if (block.style == _BlockStyle.bullet) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.circle,
              size: 5,
              color: AppColors.brandCrimson.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(block.text, style: bodyStyle)),
        ],
      );
    }

    final style = block.style == _BlockStyle.lead
        ? bodyStyle?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.warmBlack,
          )
        : bodyStyle;

    return Text(block.text, style: style);
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
            l10n.privacyPolicyContactTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warmBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.privacyPolicyContactIntro,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.warmTaupe,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.privacyPolicyContactEmail,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.headset_mic_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.privacyPolicyContactInApp,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.privacyPolicyContactLocation,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
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
