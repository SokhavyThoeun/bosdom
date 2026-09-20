import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/currency_provider.dart';

/// Mock riel/dollar rate used only for display conversion — every price in
/// the app is stored/keyed in USD, this app has no live FX feed.
const kMockKhrPerUsd = 4100.0;

String formatUsd(double usd) =>
    '\$${NumberFormat('#,##0.00', 'en_US').format(usd)}';

String formatKhr(double usd) {
  final khr = ((usd * kMockKhrPerUsd) / 100).round() * 100;
  return '៛${NumberFormat('#,##0', 'en_US').format(khr)}';
}

/// [usd] formatted in the user's selected display currency
/// ([currencyProvider]) — the display-layer counterpart to a price that is
/// always stored in USD.
String formatPrice(WidgetRef ref, double usd) {
  final currency = ref.watch(currencyProvider);
  return currency == AppCurrency.usd ? formatUsd(usd) : formatKhr(usd);
}

/// A "≈ ..." string in the other currency for [usd] when the user has
/// "show both currencies" enabled, else `null`.
String? formatSecondaryPrice(WidgetRef ref, double usd) {
  if (!ref.watch(showBothCurrenciesProvider)) return null;
  final currency = ref.watch(currencyProvider);
  final secondary = currency == AppCurrency.usd
      ? formatKhr(usd)
      : formatUsd(usd);
  return '≈ $secondary';
}
