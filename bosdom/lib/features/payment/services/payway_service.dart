import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';

/// An open ABA PayWay KHQR transaction, as returned by `POST /payments/khqr`.
class KhqrPayment {
  const KhqrPayment({
    required this.tranId,
    required this.amount,
    required this.currency,
    required this.qrString,
    required this.deeplink,
    required this.expiresAt,
    this.sandboxApproveAfter,
  });

  factory KhqrPayment.fromJson(Map<String, dynamic> json) => KhqrPayment(
    tranId: json['tran_id'] as String,
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    qrString: json['qr_string'] as String,
    deeplink: json['deeplink'] as String? ?? '',
    expiresAt: DateTime.parse(json['expires_at'] as String).toLocal(),
    sandboxApproveAfter: switch (json['sandbox_approve_after_seconds']) {
      final int seconds => Duration(seconds: seconds),
      _ => null,
    },
  );

  final String tranId;

  /// What PayWay actually charges (USD): items + shipping + escrow fee,
  /// computed by the backend.
  final double amount;
  final String currency;
  final String qrString;

  /// Opens this payment straight in ABA Mobile.
  final String deeplink;
  final DateTime expiresAt;

  /// Sandbox only: sandbox QR codes can't be paid by a real banking app, so
  /// the sheet stands in for a scan by calling [PaywayService.sandboxApprove]
  /// once this has passed. `null` on production.
  final Duration? sandboxApproveAfter;
}

/// An open ABA PayWay card payment, as returned by `POST /payments/card`.
/// The card itself is typed into PayWay's hosted page, never into this app.
class CardCheckout {
  const CardCheckout({
    required this.tranId,
    required this.amount,
    required this.checkoutUrl,
    required this.successUrl,
    required this.cancelUrl,
  });

  factory CardCheckout.fromJson(Map<String, dynamic> json) => CardCheckout(
    tranId: json['tran_id'] as String,
    amount: (json['amount'] as num).toDouble(),
    checkoutUrl: json['checkout_url'] as String,
    successUrl: json['success_url'] as String,
    cancelUrl: json['cancel_url'] as String,
  );

  final String tranId;

  /// What PayWay actually charges (USD), computed by the backend.
  final double amount;

  /// Backend page that hands the WebView over to PayWay's card page.
  final String checkoutUrl;

  /// Where PayWay sends the buyer when they finish or back out.
  final String successUrl;
  final String cancelUrl;
}

/// Status of a PayWay payment, KHQR or card.
enum PaywayPaymentStatus { pending, paid, expired, failed, refundDue }

/// A payment request the backend refused, with its reason.
class PaymentException implements Exception {
  const PaymentException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class PaywayService {
  static const _timeout = ApiConfig.requestTimeout;

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  /// Opens a KHQR payment for one checkout's [orderIds], or for the
  /// buyer's pending join on [coBuyPoolId].
  static Future<KhqrPayment> startKhqr({
    List<String> orderIds = const [],
    String? coBuyPoolId,
    double shippingFee = 0,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/payments/khqr'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'order_ids': orderIds,
            'co_buy_pool_id': coBuyPoolId,
            'shipping_fee': shippingFee,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw PaymentException(_detail(response));
    }
    return KhqrPayment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Opens a card payment for one checkout's [orderIds], or for the buyer's
  /// pending join on [coBuyPoolId].
  static Future<CardCheckout> startCard({
    List<String> orderIds = const [],
    String? coBuyPoolId,
    double shippingFee = 0,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/payments/card'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'order_ids': orderIds,
            'co_buy_pool_id': coBuyPoolId,
            'shipping_fee': shippingFee,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw PaymentException(_detail(response));
    }
    return CardCheckout.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// The payment's current status. The backend confirms it with PayWay on
  /// every call, so polling this is how the app learns a payment went through.
  static Future<PaywayPaymentStatus> status(String tranId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/payments/$tranId'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw PaymentException(_detail(response));
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return switch (body['status']) {
      'paid' => PaywayPaymentStatus.paid,
      'expired' => PaywayPaymentStatus.expired,
      'failed' => PaywayPaymentStatus.failed,
      'refund_due' => PaywayPaymentStatus.refundDue,
      _ => PaywayPaymentStatus.pending,
    };
  }

  /// Sandbox stand-in for a KHQR scan: marks the payment paid.
  static Future<void> sandboxApprove(String tranId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/payments/$tranId/sandbox-approve'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw PaymentException(_detail(response));
    }
  }

  static String _detail(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      final detail = body is Map ? body['detail'] : null;
      if (detail is String) return detail;
    } on FormatException {
      // Not JSON — fall through to the raw body.
    }
    return response.body;
  }
}
