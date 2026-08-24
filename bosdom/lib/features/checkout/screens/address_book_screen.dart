import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../models/address.dart';
import '../providers/address_provider.dart';

class AddressBookScreen extends ConsumerWidget {
  const AddressBookScreen({super.key, this.selectionMode = false});

  /// When true, this screen was opened to pick a delivery address for an
  /// in-progress checkout: selecting an address sets it as default and
  /// immediately returns to the caller.
  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final addresses = ref.watch(addressBookProvider);

    return Scaffold(
      body: Column(
        children: [
          _AddressBookHeader(
            colorScheme: colorScheme,
            textTheme: textTheme,
            subtitle: selectionMode
                ? l10n.addressBookSelectionSubtitle
                : null,
          ),
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
                  for (final address in addresses) ...[
                    _AddressCard(
                      address: address,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onSelect: () {
                        ref
                            .read(addressBookProvider.notifier)
                            .setDefault(address.id);
                        if (selectionMode) context.pop();
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.pushNamed('addAddress', extra: selectionMode),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addressAddNewButton),
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

class _AddressBookHeader extends StatelessWidget {
  const _AddressBookHeader({
    required this.colorScheme,
    required this.textTheme,
    this.subtitle,
  });

  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String? subtitle;

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
          height: subtitle == null ? 96 : 116,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: InkWell(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed('marketplace');
                    }
                  },
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
                l10n.addressBookScreenTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.colorScheme,
    required this.textTheme,
    required this.onSelect,
  });

  final Address address;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: address.isDefault
                  ? colorScheme.primary
                  : colorScheme.outline,
              width: address.isDefault ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                address.isDefault
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: address.isDefault
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            address.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              l10n.addressDefaultBadge,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (address.addressLine.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        address.addressLine,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      address.cityLine,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address.phone,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
