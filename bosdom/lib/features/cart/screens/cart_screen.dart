import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/checkout_progress_stepper.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final groups = notifier.groups;

    final totalItems = groups.fold(0, (sum, group) => sum + group.lines.length);
    final allSelected =
        groups.isNotEmpty && groups.every((group) => group.allSelected);
    final subtotal = groups
        .expand((group) => group.lines)
        .where((line) => line.selected)
        .fold(0.0, (sum, line) => sum + line.lineTotal);
    const shipping = 45.0;
    final escrowFee = subtotal * 0.02;
    final total = subtotal + (subtotal > 0 ? shipping : 0) + escrowFee;

    void moveToWishlist(CartLine line) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cartMovedToWishlistSnackbar(line.product.name)),
        ),
      );
      notifier.removeLine(line);
    }

    return Scaffold(
      body: Column(
        children: [
          _Header(colorScheme: colorScheme, textTheme: textTheme),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: groups.isEmpty
                  ? _EmptyState(colorScheme: colorScheme, textTheme: textTheme)
                  : ListView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        24,
                        24,
                        8 + MediaQuery.of(context).padding.bottom,
                      ),
                      children: [
                        const CheckoutProgressStepper(
                          currentStep: CheckoutStep.cart,
                        ),
                        const SizedBox(height: 20),
                        _SelectAllBar(
                          allSelected: allSelected,
                          itemCount: totalItems,
                          onChanged: notifier.toggleAll,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 16),
                        for (final group in groups) ...[
                          _CartGroupCard(
                            group: group,
                            onGroupToggle: (value) =>
                                notifier.toggleGroup(group, value),
                            onLineToggle: notifier.toggleLine,
                            onQuantityChanged: notifier.changeQuantity,
                            onWishlist: moveToWishlist,
                            onDelete: notifier.removeLine,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                          ),
                          const SizedBox(height: 16),
                        ],
                        _OrderSummary(
                          subtotal: subtotal,
                          shipping: subtotal > 0 ? shipping : 0,
                          escrowFee: escrowFee,
                          total: total,
                          colorScheme: colorScheme,
                          textTheme: textTheme,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: subtotal > 0
                              ? () => context.pushNamed('checkout')
                              : null,
                          child: Text(l10n.cartProceedToCheckout),
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

const _kHeaderContentHeight = 96.0;

class _Header extends StatelessWidget {
  const _Header({required this.colorScheme, required this.textTheme});

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
          height: _kHeaderContentHeight,
          child: Center(
            child: Text(
              l10n.cartScreenTitle,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectAllBar extends StatelessWidget {
  const _SelectAllBar({
    required this.allSelected,
    required this.itemCount,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  final bool allSelected;
  final int itemCount;
  final ValueChanged<bool?> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 4),
          Text(
            l10n.cartSelectAll,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(
            l10n.cartItemsCount(itemCount),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartGroupCard extends StatelessWidget {
  const _CartGroupCard({
    required this.group,
    required this.onGroupToggle,
    required this.onLineToggle,
    required this.onQuantityChanged,
    required this.onWishlist,
    required this.onDelete,
    required this.colorScheme,
    required this.textTheme,
  });

  final CartGroup group;
  final ValueChanged<bool?> onGroupToggle;
  final void Function(CartLine line, bool? value) onLineToggle;
  final void Function(CartLine line, int delta) onQuantityChanged;
  final void Function(CartLine line) onWishlist;
  final void Function(CartLine line) onDelete;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Checkbox(
                value: group.allSelected,
                onChanged: onGroupToggle,
                activeColor: colorScheme.primary,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 11,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.storefront_outlined,
                  size: 13,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  group.seller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.cartItemsCount(group.lines.length),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          for (final line in group.lines) ...[
            const Divider(height: 16),
            _CartLineTile(
              line: line,
              onToggle: (value) => onLineToggle(line, value),
              onQuantityChanged: (delta) => onQuantityChanged(line, delta),
              onWishlist: () => onWishlist(line),
              onDelete: () => onDelete(line),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],
        ],
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  const _CartLineTile({
    required this.line,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onWishlist,
    required this.onDelete,
    required this.colorScheme,
    required this.textTheme,
  });

  final CartLine line;
  final ValueChanged<bool?> onToggle;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onWishlist;
  final VoidCallback onDelete;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final product = line.product;
    final l10n = AppLocalizations.of(context);

    return Slidable(
      key: ValueKey(product.name),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.4,
        children: [
          SlidableAction(
            onPressed: (_) => onWishlist(),
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            icon: Icons.favorite_border,
            label: l10n.cartWishlistAction,
          ),
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: Icons.delete_outline,
            label: l10n.commonDelete,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: line.selected,
            onChanged: onToggle,
            activeColor: colorScheme.primary,
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 6),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(product.icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.cartUnitPrice(product.price),
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '\$${line.lineTotal.toStringAsFixed(2)}',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    _QuantityStepper(
                      quantity: line.quantity,
                      onChanged: onQuantityChanged,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onChanged,
    required this.colorScheme,
    required this.textTheme,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          onTap: () => onChanged(-1),
          colorScheme: colorScheme,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$quantity',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          onTap: () => onChanged(1),
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
  });

  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary),
          ),
          child: Icon(icon, size: 14, color: colorScheme.primary),
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({
    required this.subtotal,
    required this.shipping,
    required this.escrowFee,
    required this.total,
    required this.colorScheme,
    required this.textTheme,
  });

  final double subtotal;
  final double shipping;
  final double escrowFee;
  final double total;
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(
            label: l10n.cartSubtotal,
            value: subtotal,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.cartEstimatedShipping,
            value: shipping,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.cartEscrowFee,
            value: escrowFee,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const Divider(height: 24),
          Row(
            children: [
              Text(
                l10n.cartTotalAmount,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.colorScheme,
    required this.textTheme,
  });

  final String label;
  final double value;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cartEmptyState,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
