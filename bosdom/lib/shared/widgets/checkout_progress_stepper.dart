import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

enum CheckoutStep { cart, checkout, payment }

/// Cart → Checkout → Payment progress indicator shown atop each screen
/// in the purchase flow, with the step matching the current screen marked.
class CheckoutProgressStepper extends StatelessWidget {
  const CheckoutProgressStepper({
    super.key,
    required this.currentStep,
    this.completed = false,
  });

  final CheckoutStep currentStep;

  /// Marks [currentStep] itself as done too (e.g. once an order is confirmed),
  /// instead of just in-progress.
  final bool completed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final currentIndex = completed ? currentStep.index + 1 : currentStep.index;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepNode(
          label: l10n.checkoutStepCart,
          done: currentIndex > 0,
          current: currentIndex == 0,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        _StepConnector(done: currentIndex > 0, colorScheme: colorScheme),
        _StepNode(
          label: l10n.checkoutStepCheckout,
          done: currentIndex > 1,
          current: currentIndex == 1,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
        _StepConnector(done: currentIndex > 1, colorScheme: colorScheme),
        _StepNode(
          label: l10n.checkoutStepPayment,
          done: currentIndex > 2,
          current: currentIndex == 2,
          colorScheme: colorScheme,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.label,
    required this.done,
    required this.current,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final bool done;
  final bool current;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? colorScheme.tertiary : Colors.white,
            border: Border.all(
              color: current ? colorScheme.primary : colorScheme.outline,
              width: current ? 2 : 1,
            ),
          ),
          child: done
              ? Icon(Icons.check, color: colorScheme.onTertiary, size: 20)
              : current
              ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            color: current ? colorScheme.primary : colorScheme.onSurface,
            fontWeight: current ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StepConnector extends StatelessWidget {
  const _StepConnector({required this.done, required this.colorScheme});

  final bool done;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 17, left: 4, right: 4),
        child: Container(
          height: 2,
          color: done ? colorScheme.tertiary : colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
