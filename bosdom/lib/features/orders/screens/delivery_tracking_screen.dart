import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';

// All statuses share the brand color instead of a traffic-light palette —
// status is distinguished by icon and label, not by hue.
Color _statusColor(OrderStatus status) => AppColors.brandCrimson;

enum _StepState { done, current, pending }

class _TrackingStep {
  const _TrackingStep({
    required this.title,
    required this.timeLabel,
    required this.state,
    required this.icon,
  });

  final String title;
  final String? timeLabel;
  final _StepState state;
  final IconData icon;
}

String _formatTime(DateTime dateTime) =>
    DateFormat.yMMMd().add_jm().format(dateTime.toLocal());

/// Steps mirror the backend's real escrow state machine (`orders.py`) —
/// there's no courier webhook data to show a packed/shipped/out-for-delivery
/// timeline, so each step's timestamp comes straight off the order's own
/// `paid_at`/`released_at`/`cancelled_at`/`refunded_at` columns.
List<_TrackingStep> _stepsFor(Order order, AppLocalizations l10n) {
  final placed = _TrackingStep(
    title: l10n.deliveryStepOrderPlaced,
    timeLabel: _formatTime(order.createdAt),
    state: _StepState.done,
    icon: Icons.receipt_long_outlined,
  );

  if (order.status == OrderStatus.cancelled) {
    return [
      placed,
      _TrackingStep(
        title: l10n.deliveryStepOrderCancelled,
        timeLabel: order.cancelledAt != null
            ? _formatTime(order.cancelledAt!)
            : null,
        state: _StepState.current,
        icon: Icons.cancel_outlined,
      ),
    ];
  }

  final steps = [
    placed,
    if (order.status == OrderStatus.pendingPayment)
      _TrackingStep(
        title: l10n.deliveryStepPaymentHeld,
        timeLabel: null,
        state: _StepState.current,
        icon: Icons.lock_clock_outlined,
      )
    else
      _TrackingStep(
        title: l10n.deliveryStepPaymentHeld,
        timeLabel: order.paidAt != null ? _formatTime(order.paidAt!) : null,
        state: _StepState.done,
        icon: Icons.lock_clock_outlined,
      ),
  ];

  switch (order.status) {
    case OrderStatus.pendingPayment:
      steps.add(
        _TrackingStep(
          title: l10n.deliveryStepReleased,
          timeLabel: null,
          state: _StepState.pending,
          icon: Icons.check_circle_outline,
        ),
      );
    case OrderStatus.held:
      steps.add(
        _TrackingStep(
          title: l10n.deliveryStepReleased,
          timeLabel: null,
          state: _StepState.current,
          icon: Icons.check_circle_outline,
        ),
      );
    case OrderStatus.released:
      steps.add(
        _TrackingStep(
          title: l10n.deliveryStepReleased,
          timeLabel: order.releasedAt != null
              ? _formatTime(order.releasedAt!)
              : null,
          state: _StepState.done,
          icon: Icons.check_circle_outline,
        ),
      );
    case OrderStatus.disputed:
      steps.add(
        _TrackingStep(
          title: l10n.deliveryStepDisputed,
          timeLabel: null,
          state: _StepState.current,
          icon: Icons.report_problem_outlined,
        ),
      );
    case OrderStatus.refunded:
      steps.add(
        _TrackingStep(
          title: l10n.deliveryStepDisputed,
          timeLabel: null,
          state: _StepState.done,
          icon: Icons.report_problem_outlined,
        ),
      );
      steps.add(
        _TrackingStep(
          title: l10n.deliveryStepRefunded,
          timeLabel: order.refundedAt != null
              ? _formatTime(order.refundedAt!)
              : null,
          state: _StepState.done,
          icon: Icons.undo_rounded,
        ),
      );
    case OrderStatus.cancelled:
      break; // handled above
  }

  return steps;
}

class DeliveryTrackingScreen extends ConsumerWidget {
  const DeliveryTrackingScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderByIdProvider(orderId));
    return orderAsync.when(
      data: (order) => _DeliveryTrackingBody(order: order),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;
        return Scaffold(
          body: Center(
            child: EmptyProductsNotice(
              colorScheme: colorScheme,
              textTheme: textTheme,
              message: AppLocalizations.of(context).ordersLoadError,
              onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
            ),
          ),
        );
      },
    );
  }
}

class _DeliveryTrackingBody extends StatefulWidget {
  const _DeliveryTrackingBody({required this.order});

  final Order order;

  @override
  State<_DeliveryTrackingBody> createState() => _DeliveryTrackingBodyState();
}

class _DeliveryTrackingBodyState extends State<_DeliveryTrackingBody>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _entrance.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final order = widget.order;
    final statusColor = _statusColor(order.status);
    final steps = _stepsFor(order, l10n);

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
                  16,
                  20,
                  16,
                  8 + MediaQuery.of(context).padding.bottom,
                ),
                children: [
                  _AnimatedSection(
                    animation: _entrance,
                    start: 0,
                    end: 0.6,
                    child: _OrderSummaryCard(
                      order: order,
                      statusColor: statusColor,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedSection(
                    animation: _entrance,
                    start: 0.15,
                    end: 0.75,
                    child: _ProgressBanner(
                      steps: steps,
                      pulse: _pulse,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedSection(
                    animation: _entrance,
                    start: 0.3,
                    end: 0.9,
                    child: _DeliveryStatusCard(
                      steps: steps,
                      pulse: _pulse,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _AnimatedSection(
                    animation: _entrance,
                    start: 0.45,
                    end: 1,
                    child: _EscrowNote(
                      colorScheme: colorScheme,
                      textTheme: textTheme,
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

/// Fades + slides a section up into place over `[start, end]` of a shared
/// entrance animation, so the page's cards stagger in rather than popping
/// all at once.
class _AnimatedSection extends StatelessWidget {
  const _AnimatedSection({
    required this.animation,
    required this.start,
    required this.end,
    required this.child,
  });

  final Animation<double> animation;
  final double start;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      animation: curved,
      child: child,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - curved.value) * 26),
            child: child,
          ),
        );
      },
    );
  }
}

const _kHeaderContentHeight = 96.0;

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
          MediaQuery.of(context).padding.top + 16,
          24,
          20,
        ),
        child: SizedBox(
          height: _kHeaderContentHeight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Icon(
                      Icons.arrow_back,
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
              Text(
                l10n.deliveryScreenTitle,
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

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.order,
    required this.statusColor,
    required this.colorScheme,
    required this.textTheme,
  });

  final Order order;
  final Color statusColor;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.blushSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.local_mall_outlined,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.deliveryPlacedOnLabel(order.dateLabel),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  order.status.label,
                  style: textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
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

/// Gradient hero banner with a horizontal icon-stepper whose connecting
/// track animates its fill in on entrance, and whose current-step icon
/// pulses with a looping radar ring.
class _ProgressBanner extends StatelessWidget {
  const _ProgressBanner({
    required this.steps,
    required this.pulse,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<_TrackingStep> steps;
  final Animation<double> pulse;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeIndex = steps.lastIndexWhere(
      (s) => s.state != _StepState.pending,
    );
    final fraction = steps.length <= 1 ? 1.0 : activeIndex / (steps.length - 1);
    final currentStep = steps.firstWhere(
      (s) => s.state == _StepState.current,
      orElse: () => steps[activeIndex.clamp(0, steps.length - 1)],
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, AppColors.deepBurgundy],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentStep.title,
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            currentStep.timeLabel ?? l10n.deliveryInProgressLabel,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth - 34;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 17,
                      child: Container(
                        height: 3,
                        width: trackWidth,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 17,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: fraction.clamp(0.0, 1.0)),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => Container(
                          height: 3,
                          width: trackWidth * value,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final step in steps)
                          _StepIcon(step: step, pulse: pulse),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  const _StepIcon({required this.step, required this.pulse});

  final _TrackingStep step;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    final isDone = step.state == _StepState.done;
    final isCurrent = step.state == _StepState.current;
    final isActive = isDone || isCurrent;

    final core = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.18),
      ),
      child: Icon(
        isDone ? Icons.check_rounded : step.icon,
        size: 18,
        color: isActive
            ? AppColors.brandCrimson
            : Colors.white.withValues(alpha: 0.75),
      ),
    );

    if (!isCurrent) return core;

    return AnimatedBuilder(
      animation: pulse,
      child: core,
      builder: (context, child) {
        return SizedBox(
          width: 34,
          height: 34,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Opacity(
                opacity: (1 - pulse.value) * 0.55,
                child: Transform.scale(
                  scale: 1 + pulse.value * 0.7,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              child!,
            ],
          ),
        );
      },
    );
  }
}

class _DeliveryStatusCard extends StatelessWidget {
  const _DeliveryStatusCard({
    required this.steps,
    required this.pulse,
    required this.colorScheme,
    required this.textTheme,
  });

  final List<_TrackingStep> steps;
  final Animation<double> pulse;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.deliveryStatusSectionTitle,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++)
            _StepRow(
              step: steps[i],
              isLast: i == steps.length - 1,
              pulse: pulse,
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.pulse,
    required this.colorScheme,
    required this.textTheme,
  });

  final _TrackingStep step;
  final bool isLast;
  final Animation<double> pulse;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDone = step.state == _StepState.done;
    final isCurrent = step.state == _StepState.current;
    final isActive = isDone || isCurrent;

    final iconColor = isActive ? colorScheme.primary : colorScheme.outline;
    final titleColor = isCurrent
        ? colorScheme.primary
        : isDone
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    final iconCircle = Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? colorScheme.primary.withValues(alpha: 0.12)
            : colorScheme.surfaceContainerHighest,
        border: isCurrent
            ? Border.all(color: colorScheme.primary, width: 1.5)
            : null,
      ),
      child: Icon(
        isDone ? Icons.check_rounded : step.icon,
        size: 15,
        color: iconColor,
      ),
    );

    return IntrinsicHeight(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.symmetric(
          horizontal: isCurrent ? 8 : 0,
          vertical: isCurrent ? 6 : 0,
        ),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.blushSurface.withValues(alpha: 0.6)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                isCurrent
                    ? AnimatedBuilder(
                        animation: pulse,
                        child: iconCircle,
                        builder: (context, child) => Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Opacity(
                              opacity: (1 - pulse.value) * 0.5,
                              child: Transform.scale(
                                scale: 1 + pulse.value * 0.55,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            child!,
                          ],
                        ),
                      )
                    : iconCircle,
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDone
                          ? colorScheme.primary.withValues(alpha: 0.35)
                          : colorScheme.outlineVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 4 : 18, top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: textTheme.bodyMedium?.copyWith(
                        color: titleColor,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step.timeLabel ??
                          (isCurrent
                              ? l10n.deliveryCurrentStatusLabel
                              : l10n.deliveryPendingLabel),
                      style: textTheme.bodySmall?.copyWith(
                        color: isCurrent
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EscrowNote extends StatelessWidget {
  const _EscrowNote({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blushSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.deliveryEscrowNoteText,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
