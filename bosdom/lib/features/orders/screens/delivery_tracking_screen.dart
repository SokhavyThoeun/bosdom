import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/hourglass_icon.dart';
import '../../../shared/widgets/order_review_card.dart';
import '../../../shared/widgets/order_status_badge.dart';
import '../../marketplace/widgets/empty_products_notice.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_hold_card.dart';
import 'rate_review_sheet.dart';

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

/// Steps mirror the backend's real escrow state machine (`orders.py`), but
/// are worded around order fulfillment (has the seller started working on
/// it yet?) rather than the escrow ledger — that money-processing framing
/// belongs to the seller's earnings screen, not the buyer's tracking view.
/// There's no courier webhook data to show a packed/shipped/out-for-delivery
/// timeline, so each step's timestamp comes straight off the order's own
/// `paid_at`/`seller_confirmed_at`/`released_at`/`cancelled_at`/`refunded_at`
/// columns.
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

  final steps = [placed];

  if (order.status == OrderStatus.pendingPayment) {
    steps.add(
      _TrackingStep(
        title: l10n.deliveryStepAwaitingSellerConfirmation,
        timeLabel: null,
        state: _StepState.pending,
        icon: Icons.hourglass_top_rounded,
      ),
    );
    steps.add(
      _TrackingStep(
        title: l10n.deliveryStepDelivery,
        timeLabel: null,
        state: _StepState.pending,
        icon: Icons.local_shipping_outlined,
      ),
    );
    steps.add(
      _TrackingStep(
        title: l10n.deliveryStepReleased,
        timeLabel: null,
        state: _StepState.pending,
        icon: Icons.check_circle_outline,
      ),
    );
    return steps;
  }

  // Only held/released/disputed/refunded reach here (pendingPayment and
  // cancelled both return above).
  final confirmationState = order.isSellerConfirmed
      ? _StepState.done
      : _StepState.current;
  steps.add(
    _TrackingStep(
      title: order.isSellerConfirmed
          ? l10n.deliveryStepSellerProcessing
          : l10n.deliveryStepAwaitingSellerConfirmation,
      timeLabel: order.sellerConfirmedAt != null
          ? _formatTime(order.sellerConfirmedAt!)
          : null,
      state: confirmationState,
      icon: order.isSellerConfirmed
          ? Icons.task_alt_rounded
          : Icons.hourglass_top_rounded,
    ),
  );

  final deliveryState = switch (order.status) {
    OrderStatus.held =>
      order.isSellerConfirmed ? _StepState.current : _StepState.pending,
    OrderStatus.released || OrderStatus.disputed || OrderStatus.refunded =>
      order.isSellerConfirmed ? _StepState.done : _StepState.pending,
    _ => _StepState.pending,
  };
  steps.add(
    _TrackingStep(
      title: l10n.deliveryStepDelivery,
      timeLabel: null,
      state: deliveryState,
      icon: Icons.local_shipping_outlined,
    ),
  );

  switch (order.status) {
    case OrderStatus.held:
      steps.add(
        _TrackingStep(
          title: l10n.deliveryStepReleased,
          timeLabel: null,
          state: _StepState.pending,
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
    case OrderStatus.pendingPayment:
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

class _DeliveryTrackingBody extends ConsumerStatefulWidget {
  const _DeliveryTrackingBody({required this.order});

  final Order order;

  @override
  ConsumerState<_DeliveryTrackingBody> createState() =>
      _DeliveryTrackingBodyState();
}

class _DeliveryTrackingBodyState extends ConsumerState<_DeliveryTrackingBody>
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
                  if (order.status == OrderStatus.disputed &&
                      order.holdSource != null) ...[
                    const SizedBox(height: 16),
                    OrderHoldCard(order: order),
                  ],
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
                  if (order.status == OrderStatus.released) ...[
                    const SizedBox(height: 16),
                    _AnimatedSection(
                      animation: _entrance,
                      start: 0.55,
                      end: 1,
                      child: order.review != null
                          ? _ReviewSummaryCard(
                              review: order.review!,
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            )
                          : _RateOrderButton(
                              onTap: () => showRateReviewSheet(context, order),
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Replaces [_RateOrderButton] once the buyer has already left a review —
/// same card the seller's order detail screen shows, so "what did I say"
/// looks the same wherever the buyer checks back on it.
class _ReviewSummaryCard extends StatelessWidget {
  const _ReviewSummaryCard({
    required this.review,
    required this.colorScheme,
    required this.textTheme,
  });

  final OrderReview review;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reviewSectionTitle.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          OrderReviewCard(review: review),
        ],
      ),
    );
  }
}

class _RateOrderButton extends StatelessWidget {
  const _RateOrderButton({
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.star_outline_rounded),
        label: Text(
          l10n.ordersRateReviewButton,
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
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

const _kHeaderContentHeight = 68.0;

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
    required this.colorScheme,
    required this.textTheme,
  });

  final Order order;
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
                  '#${order.displayNumber}',
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
          OrderStatusBadge(
            label: buyerOrderStatusLabel(
              order.status,
              isSellerConfirmed: order.isSellerConfirmed,
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
            height: 34,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  _StepIcon(step: steps[i], pulse: pulse),
                  if (i != steps.length - 1)
                    Expanded(
                      child: _StepLine(
                        fraction: fraction,
                        index: i,
                        segmentCount: steps.length - 1,
                      ),
                    ),
                ],
              ],
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
    final isFlippingHourglass =
        isCurrent && step.icon == Icons.hourglass_top_rounded;

    final core = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.18),
      ),
      child: isFlippingHourglass
          ? HourglassIcon(size: 18, color: AppColors.brandCrimson)
          : Icon(
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

class _StepLine extends StatelessWidget {
  const _StepLine({
    required this.fraction,
    required this.index,
    required this.segmentCount,
  });

  final double fraction;
  final int index;
  final int segmentCount;

  @override
  Widget build(BuildContext context) {
    final segmentFraction = segmentCount <= 0
        ? 0.0
        : ((fraction * segmentCount) - index).clamp(0.0, 1.0);

    return SizedBox(
      height: 3,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: segmentFraction),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
    final isFlippingHourglass =
        isCurrent && step.icon == Icons.hourglass_top_rounded;

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
      child: isFlippingHourglass
          ? HourglassIcon(size: 15, color: iconColor)
          : Icon(
              isDone ? Icons.check_rounded : step.icon,
              size: 15,
              color: iconColor,
            ),
    );

    return IntrinsicHeight(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.gpp_good_outlined,
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
