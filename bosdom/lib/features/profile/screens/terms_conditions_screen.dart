import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

enum _BlockStyle { paragraph, bullet, lead }

class _TermsBlock {
  const _TermsBlock(this.text, this.style);

  final String text;
  final _BlockStyle style;
}

class _TermsSection {
  const _TermsSection(this.title, this.blocks);

  final String title;
  final List<_TermsBlock> blocks;
}

List<_TermsSection> _sections(AppLocalizations l10n) => [
  _TermsSection(l10n.termsConditionsSection1Title, [
    _TermsBlock(l10n.termsConditionsSection1Point1, _BlockStyle.paragraph),
    _TermsBlock(l10n.termsConditionsSection1Point2, _BlockStyle.lead),
    _TermsBlock(l10n.termsConditionsSection1Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection1Point4, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection1Point5, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection1Point6, _BlockStyle.bullet),
  ]),
  _TermsSection(l10n.termsConditionsSection2Title, [
    _TermsBlock(l10n.termsConditionsSection2Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection2Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection2Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection2Point4, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection2Point5, _BlockStyle.bullet),
  ]),
  _TermsSection(l10n.termsConditionsSection3Title, [
    _TermsBlock(l10n.termsConditionsSection3Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection3Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection3Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection3Point4, _BlockStyle.bullet),
  ]),
  _TermsSection(l10n.termsConditionsSection4Title, [
    _TermsBlock(l10n.termsConditionsSection4Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection4Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection4Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection4Point4, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection4Point5, _BlockStyle.bullet),
  ]),
  _TermsSection(l10n.termsConditionsSection5Title, [
    _TermsBlock(l10n.termsConditionsSection5Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection5Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection5Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection5Point4, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection5Point5, _BlockStyle.bullet),
  ]),
  _TermsSection(l10n.termsConditionsSection6Title, [
    _TermsBlock(l10n.termsConditionsSection6Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection6Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection6Point3, _BlockStyle.lead),
    _TermsBlock(l10n.termsConditionsSection6Point4, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection6Point5, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection6Point6, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection6Point7, _BlockStyle.paragraph),
  ]),
  _TermsSection(l10n.termsConditionsSection7Title, [
    _TermsBlock(l10n.termsConditionsSection7Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection7Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection7Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection7Point4, _BlockStyle.bullet),
  ]),
  _TermsSection(l10n.termsConditionsSection8Title, [
    _TermsBlock(l10n.termsConditionsSection8Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection8Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection8Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection8Point4, _BlockStyle.bullet),
  ]),
  _TermsSection(l10n.termsConditionsSection9Title, [
    _TermsBlock(l10n.termsConditionsSection9Point1, _BlockStyle.lead),
    _TermsBlock(l10n.termsConditionsSection9Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection9Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection9Point4, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection9Point5, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection9Point6, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection9Point7, _BlockStyle.paragraph),
  ]),
  _TermsSection(l10n.termsConditionsSection10Title, [
    _TermsBlock(l10n.termsConditionsSection10Point1, _BlockStyle.lead),
    _TermsBlock(l10n.termsConditionsSection10Point2, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection10Point3, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection10Point4, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection10Point5, _BlockStyle.paragraph),
  ]),
  _TermsSection(l10n.termsConditionsSection11Title, [
    _TermsBlock(l10n.termsConditionsSection11Point1, _BlockStyle.paragraph),
    _TermsBlock(l10n.termsConditionsSection11Point2, _BlockStyle.paragraph),
  ]),
  _TermsSection(l10n.termsConditionsSection12Title, [
    _TermsBlock(l10n.termsConditionsSection12Point1, _BlockStyle.bullet),
    _TermsBlock(l10n.termsConditionsSection12Point2, _BlockStyle.bullet),
  ]),
];

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          _TermsHeader(colorScheme: colorScheme, textTheme: textTheme),
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
                    l10n.termsConditionsLastUpdated,
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

class _TermsHeader extends StatelessWidget {
  const _TermsHeader({required this.colorScheme, required this.textTheme});

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
                l10n.termsConditionsScreenTitle,
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

  final _TermsSection section;
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
              child: _TermsBlockView(block: block, textTheme: textTheme),
            ),
        ],
      ),
    );
  }
}

class _TermsBlockView extends StatelessWidget {
  const _TermsBlockView({required this.block, required this.textTheme});

  final _TermsBlock block;
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
        ? bodyStyle?.copyWith(fontWeight: FontWeight.w700, color: AppColors.warmBlack)
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
            l10n.termsConditionsContactTitle,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.warmBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.termsConditionsContactIntro,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.warmTaupe,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.mail_outline_rounded, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.termsConditionsContactEmail,
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
              Icon(Icons.headset_mic_outlined, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.termsConditionsContactInApp,
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
