import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../models/order.dart';

/// The fund-release process for one order, shown to both buyer and seller:
/// order placed (held in escrow) → seller prepares → shipped (photo + tracking)
/// → review timer, which turns into an auto release to the seller once it runs
/// out with no report. A reported problem freezes the timer and hands the
/// order to an admin. Each reached step shows when it happened.
class ReleaseFlowCard extends StatefulWidget {
  const ReleaseFlowCard({super.key, required this.order});

  final Order order;

  @override
  State<ReleaseFlowCard> createState() => _ReleaseFlowCardState();
}

class _ReleaseFlowCardState extends State<ReleaseFlowCard>
    with TickerProviderStateMixin {
  static const _stepCount = 4;

  Timer? _ticker;
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    // Keeps the countdown fresh; minute precision is all the timer shows.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  static String _formatLeft(Duration left) {
    if (left.isNegative) return '0m';
    if (left.inHours >= 24) return '${left.inDays}d ${left.inHours % 24}h';
    if (left.inHours >= 1) return '${left.inHours}h ${left.inMinutes % 60}m';
    return '${left.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final released = order.status == OrderStatus.released;
    final disputed = order.status == OrderStatus.disputed;
    final timerRunning =
        order.status == OrderStatus.held && order.reviewDeadlineAt != null;

    final prepared = order.sellerConfirmedAt != null || order.isShipped;
    final timerDone = released;
    final timerReached = order.isDelivered || released;

    final steps = <_FlowStep>[
      _FlowStep(
        l10n.escrowStepPaidTitle,
        l10n.escrowStepPaidDetail,
        done: order.paidAt != null,
        at: order.paidAt,
      ),
      _FlowStep(
        l10n.escrowStepPreparesTitle,
        l10n.escrowStepPreparesDetail,
        done: prepared,
        at: order.sellerConfirmedAt ?? order.shippedAt,
      ),
      _FlowStep(
        l10n.escrowStepShippedTitle,
        order.isShipped && order.trackingNumber != null
            ? l10n.escrowTrackingLabel(
                order.courier ?? '',
                order.trackingNumber!,
              )
            : l10n.escrowStepShippedDetail,
        done: order.isShipped,
        at: order.shippedAt,
        photoUrl: order.shippingPhotoUrl,
      ),
      _FlowStep(
        timerDone ? l10n.escrowStepReleaseTitle : l10n.escrowStepTimerTitle,
        timerDone
            ? l10n.escrowStepReleaseDetail
            : timerRunning
            ? l10n.escrowTimerLeft(
                _formatLeft(order.reviewDeadlineAt!.difference(DateTime.now())),
              )
            : l10n.escrowStepTimerDetail,
        done: timerReached,
        at: timerDone ? order.releasedAt : order.deliveredAt,
        photoUrl: order.deliveryProofUrl,
        problem: disputed,
      ),
    ];
    assert(steps.length == _stepCount);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.escrowFlowTitle.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedBuilder(
            animation: Listenable.merge([_intro, _pulse]),
            builder: (context, _) {
              // First not-yet-done step is the one the order is waiting on.
              final current = steps.indexWhere((s) => !s.done);
              return Column(
                children: [
                  for (var i = 0; i < steps.length; i++)
                    _StepRow(
                      step: steps[i],
                      last: i == steps.length - 1,
                      // Each step fills in after the one before it.
                      reveal: Curves.easeOut.transform(
                        Interval(
                          i / _stepCount,
                          (i + 1) / _stepCount,
                        ).transform(_intro.value),
                      ),
                      pulse: i == current && !disputed ? _pulse.value : null,
                    ),
                ],
              );
            },
          ),
          if (disputed) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.pause_circle_outline, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.escrowTimerFrozen,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FlowStep {
  const _FlowStep(
    this.title,
    this.detail, {
    required this.done,
    this.at,
    this.photoUrl,
    this.problem = false,
  });

  final String title;
  final String detail;
  final bool done;
  final DateTime? at;
  final String? photoUrl;
  final bool problem;
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.last,
    required this.reveal,
    required this.pulse,
  });

  static final _timeFormat = DateFormat('MMM d, y · h:mm a');

  final _FlowStep step;
  final bool last;

  /// 0→1 as this step's entrance animation plays.
  final double reveal;

  /// 0→1 breathing value when this is the step being waited on, else null.
  final double? pulse;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = step.problem
        ? colorScheme.primary
        : step.done
        ? AppColors.trustGreen
        : colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                SizedBox(
                  width: 26,
                  height: 22,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (pulse != null)
                        Transform.scale(
                          scale: 1 + 0.55 * pulse!,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.trustGreen.withValues(
                                alpha: 0.28 * (1 - pulse!),
                              ),
                            ),
                          ),
                        ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: step.problem
                              ? color
                              : Color.lerp(
                                  Colors.white,
                                  color,
                                  step.done ? reveal : 0,
                                ),
                          border: Border.all(color: color, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: step.done && !step.problem
                            ? Transform.scale(
                                scale: reveal,
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Stack(
                      children: [
                        // Positioned so the lines don't feed IntrinsicHeight.
                        Positioned.fill(
                          child: Align(
                            child: Container(
                              width: 2,
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                        // The green line draws itself down to the next step.
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: FractionallySizedBox(
                              heightFactor: step.done || step.problem
                                  ? reveal
                                  : 0,
                              child: Container(width: 2, color: color),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: step.done || step.problem
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          step.detail,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (step.at != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _timeFormat.format(step.at!.toLocal()),
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (step.photoUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        step.photoUrl!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(Icons.image_not_supported_outlined),
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
