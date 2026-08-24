import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';

const _kMaxAttachments = 3;

enum _IssueType {
  orderProblem,
  paymentIssue,
  appBug,
  deliveryIssue,
  accountProblem,
  other,
}

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderRefController = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _attachments = [];

  _IssueType _selectedType = _IssueType.appBug;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _orderRefController.dispose();
    super.dispose();
  }

  String _labelFor(_IssueType type, AppLocalizations l10n) {
    switch (type) {
      case _IssueType.orderProblem:
        return l10n.reportIssueTypeOrderProblem;
      case _IssueType.paymentIssue:
        return l10n.reportIssueTypePaymentIssue;
      case _IssueType.appBug:
        return l10n.reportIssueTypeAppBug;
      case _IssueType.deliveryIssue:
        return l10n.reportIssueTypeDeliveryIssue;
      case _IssueType.accountProblem:
        return l10n.reportIssueTypeAccountProblem;
      case _IssueType.other:
        return l10n.reportIssueTypeOther;
    }
  }

  Future<void> _addAttachments() async {
    final l10n = AppLocalizations.of(context);
    final remaining = _kMaxAttachments - _attachments.length;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportIssueMaxFilesSnackbar(_kMaxAttachments)),
        ),
      );
      return;
    }
    try {
      final picked = await _picker.pickMultiImage(limit: remaining);
      if (picked.isEmpty || !mounted) return;
      setState(() => _attachments.addAll(picked));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportIssuePhotoLibraryErrorSnackbar('$e')),
        ),
      );
    }
  }

  void _removeAttachment(XFile file) {
    setState(() => _attachments.remove(file));
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reportIssueSubmittedSnackbar)),
    );
    context.pop();
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
          _ReportIssueHeader(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  children: [
                    _SectionLabel(l10n.reportIssueTypeLabel),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final type in _IssueType.values)
                          _IssueTypeChip(
                            label: _labelFor(type, l10n),
                            selected: _selectedType == type,
                            onTap: () =>
                                setState(() => _selectedType = type),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(l10n.reportIssueSubjectLabel),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: l10n.reportIssueSubjectHint,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? l10n.reportIssueSubjectRequired
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(l10n.reportIssueDescriptionLabel),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: l10n.reportIssueDescriptionHint,
                        alignLabelWithHint: true,
                      ),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? l10n.reportIssueDescriptionRequired
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _SectionLabel(l10n.reportIssueAttachLabel),
                    const SizedBox(height: 12),
                    _AttachmentPicker(
                      attachments: _attachments,
                      onAdd: _addAttachments,
                      onRemove: _removeAttachment,
                      uploadLabel: l10n.reportIssueAttachTapToUpload,
                      supportsLabel: l10n.reportIssueAttachSupports(
                        _kMaxAttachments,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _SectionLabel(l10n.reportIssueOrderRefLabel),
                        const SizedBox(width: 6),
                        Text(
                          l10n.reportIssueOrderRefOptional,
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.warmTaupe,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _orderRefController,
                      decoration: InputDecoration(
                        hintText: l10n.reportIssueOrderRefHint,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _InfoNote(text: l10n.reportIssueResponseNote),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.reportIssueSubmitButton,
                              style: textTheme.labelLarge?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportIssueHeader extends StatelessWidget {
  const _ReportIssueHeader({required this.colorScheme, required this.textTheme});

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
                      : context.goNamed('helpSupport'),
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
                l10n.reportIssueScreenTitle,
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
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppColors.warmBlack,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _IssueTypeChip extends StatelessWidget {
  const _IssueTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? AppColors.blushSurface : Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? colorScheme.primary : colorScheme.outline,
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: selected ? colorScheme.primary : AppColors.warmTaupe,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentPicker extends StatelessWidget {
  const _AttachmentPicker({
    required this.attachments,
    required this.onAdd,
    required this.onRemove,
    required this.uploadLabel,
    required this.supportsLabel,
  });

  final List<XFile> attachments;
  final VoidCallback onAdd;
  final ValueChanged<XFile> onRemove;
  final String uploadLabel;
  final String supportsLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: AppColors.petalWhite,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onAdd,
            child: DottedBorderBox(
              radius: 18,
              color: colorScheme.primary.withValues(alpha: 0.45),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.blushSurface,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      uploadLabel,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supportsLabel,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warmTaupe,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final file = attachments[index];
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(file.path),
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onRemove(file),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Lightweight dashed-border box (no external dependency).
class DottedBorderBox extends StatelessWidget {
  const DottedBorderBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 16,
  });

  final Widget child;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(color: color, radius: radius),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    const dashWidth = 6.0;
    const dashGap = 5.0;

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.blushSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.roseDivider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.brandCrimson,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.deepBurgundy,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
