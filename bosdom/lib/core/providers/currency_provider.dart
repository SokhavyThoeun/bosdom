import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppCurrency { usd, khr }

const _kCurrencyPrefsKey = 'bosdom_display_currency';
const _kShowBothCurrenciesPrefsKey = 'bosdom_show_both_currencies';

/// The user's preferred display currency, set from the Profile > Payment
/// Currency screen and read anywhere a price is rendered for the user
/// (e.g. the KHQR "scan to pay" amount).
class CurrencyNotifier extends Notifier<AppCurrency> {
  @override
  AppCurrency build() {
    _restore();
    return AppCurrency.usd;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kCurrencyPrefsKey);
    if (code == AppCurrency.khr.name && state != AppCurrency.khr) {
      state = AppCurrency.khr;
    }
  }

  Future<void> setCurrency(AppCurrency currency) async {
    state = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrencyPrefsKey, currency.name);
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, AppCurrency>(
  CurrencyNotifier.new,
);

/// Whether prices should be shown in both currencies at once (e.g. the KHQR
/// "scan to pay" amount showing a "≈" line in the other currency), set from
/// the Profile > Payment Currency screen.
class ShowBothCurrenciesNotifier extends Notifier<bool> {
  @override
  bool build() {
    _restore();
    return true;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getBool(_kShowBothCurrenciesPrefsKey);
    if (stored != null && stored != state) {
      state = stored;
    }
  }

  Future<void> setShowBoth(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kShowBothCurrenciesPrefsKey, value);
  }
}

final showBothCurrenciesProvider =
    NotifierProvider<ShowBothCurrenciesNotifier, bool>(
      ShowBothCurrenciesNotifier.new,
    );
