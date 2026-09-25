import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../services/payway_service.dart';

/// Pays by Visa/Mastercard/UnionPay/JCB on ABA PayWay's hosted card page,
/// shown in a WebView — the card details go straight to PayWay. Pops `true`
/// once the backend sees PayWay approve the payment.
class CardCheckoutSheet extends StatefulWidget {
  const CardCheckoutSheet({super.key, required this.checkout});

  final CardCheckout checkout;

  @override
  State<CardCheckoutSheet> createState() => _CardCheckoutSheetState();
}

enum _SheetState { loading, ready, confirming, unavailable, failed }

class _CardCheckoutSheetState extends State<CardCheckoutSheet> {
  static const _pollInterval = Duration(seconds: 3);

  /// Reads a JSON body PayWay sent instead of its card page: `khqr` when it
  /// fell back to a QR (the request lost `payment_gate=0`), else its error
  /// message (usually a wrong hash), or '' for the normal HTML card page.
  static const _detectJsonReply = '''
(function () {
  try {
    var text = document.body ? document.body.innerText.trim() : '';
    if (text.charAt(0) !== '{') return '';
    var json = JSON.parse(text);
    if (json.qrString) return 'khqr';
    return (json.status && json.status.message) || 'error';
  } catch (e) {
    return '';
  }
})()
''';

  /// Hides PayWay's merchant strip (back arrow, logo, merchant name) so the
  /// page opens straight on the card form. `.header.text-center.bg-white` is
  /// the exact element its hosted-mobile component renders for that strip.
  static const _hideMerchantHeader = '''
(function () {
  if (document.getElementById('bosdom-hide-header')) return;
  var style = document.createElement('style');
  style.id = 'bosdom-hide-header';
  style.textContent = '.header.text-center.bg-white { display: none !important; }';
  document.head.appendChild(style);
})()
''';

  late final WebViewController _controller;
  Timer? _pollTimer;
  bool _polling = false;
  _SheetState _state = _SheetState.loading;
  String? _message;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageFinished: _onPageFinished,
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            setState(() {
              _state = _SheetState.failed;
              _message = error.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkout.checkoutUrl));
    _pollTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final url = request.url;
    if (url.startsWith(widget.checkout.successUrl)) {
      // PayWay is done with the buyer; wait for Check Transaction to agree.
      setState(() => _state = _SheetState.confirming);
      _poll();
      return NavigationDecision.prevent;
    }
    if (url.startsWith(widget.checkout.cancelUrl)) {
      Navigator.of(context).pop(false);
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _onPageFinished(String url) async {
    if (!mounted || _state == _SheetState.confirming) return;
    final host = Uri.tryParse(url)?.host ?? '';
    var reply = '';
    if (host.endsWith('payway.com.kh')) {
      _controller.runJavaScript(_hideMerchantHeader).catchError((_) {});
      try {
        final result = await _controller.runJavaScriptReturningResult(
          _detectJsonReply,
        );
        // Android hands the string back JSON-quoted, iOS doesn't.
        reply = '$result'.replaceAll(RegExp(r'^"|"$'), '');
      } catch (_) {
        reply = '';
      }
    }
    if (!mounted) return;
    setState(() {
      if (reply == 'khqr') {
        _state = _SheetState.unavailable;
      } else if (reply.isNotEmpty) {
        _state = _SheetState.failed;
        _message = reply;
      } else if (_state == _SheetState.loading) {
        _state = _SheetState.ready;
      }
    });
  }

  Future<void> _poll() async {
    if (_polling) return;
    _polling = true;
    try {
      final status = await PaywayService.status(widget.checkout.tranId);
      if (!mounted) return;
      switch (status) {
        case PaywayPaymentStatus.paid:
          _pollTimer?.cancel();
          Navigator.of(context).pop(true);
        case PaywayPaymentStatus.failed ||
            PaywayPaymentStatus.expired ||
            PaywayPaymentStatus.refundDue:
          _pollTimer?.cancel();
          setState(() {
            _state = _SheetState.failed;
            _message = null;
          });
        case PaywayPaymentStatus.pending:
          break;
      }
    } catch (_) {
      // A dropped poll is fine; the next tick tries again.
    } finally {
      _polling = false;
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.paymentCardMethodTitle,
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_state != _SheetState.ready)
                  Positioned.fill(
                    child: ColoredBox(
                      color: colorScheme.surface,
                      child: _StatusBody(
                        state: _state,
                        message: _message,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      ),
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

class _StatusBody extends StatelessWidget {
  const _StatusBody({
    required this.state,
    required this.message,
    required this.colorScheme,
    required this.textTheme,
  });

  final _SheetState state;
  final String? message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (label, isError) = switch (state) {
      _SheetState.loading || _SheetState.ready => (null, false),
      _SheetState.confirming => (l10n.paymentCardConfirmingLabel, false),
      _SheetState.unavailable => (l10n.paymentCardUnavailableLabel, true),
      _SheetState.failed => (message ?? l10n.paymentCardFailedLabel, true),
    };

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isError)
            Icon(Icons.error_outline, size: 40, color: colorScheme.error)
          else
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
          if (label != null) ...[
            const SizedBox(height: 16),
            Text(
              label,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: isError
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (isError) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.paymentCardCloseButton),
            ),
          ],
        ],
      ),
    );
  }
}
