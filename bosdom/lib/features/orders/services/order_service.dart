import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/api_config.dart';
import '../models/order.dart';

abstract final class OrderService {
  static const _timeout = Duration(seconds: 10);

  static Map<String, String> get _authHeaders {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) {
      throw Exception('Not signed in');
    }
    return {'Authorization': 'Bearer $token'};
  }

  static Future<List<Order>> fetchMyOrders() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/orders/me'), headers: _authHeaders)
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load orders: ${response.body}');
    }

    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>().map(Order.fromJson).toList();
  }

  /// A seller's public buyer reviews, newest first — no auth required.
  static Future<List<OrderReview>> fetchSellerReviews(String sellerId) async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/orders/seller/$sellerId/reviews'))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load reviews: ${response.body}');
    }

    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>().map(OrderReview.fromJson).toList();
  }

  static Future<List<Order>> fetchMySales() async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/orders/me/selling'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load sales: ${response.body}');
    }

    final body = jsonDecode(response.body) as List;
    return body.cast<Map<String, dynamic>>().map(Order.fromJson).toList();
  }

  static Future<Order> fetchOrder(String orderId) async {
    final response = await http
        .get(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to load order: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<Order> createOrder({
    required String listingId,
    required int quantity,
    String shippingName = '',
    String shippingAddress = '',
    String shippingPhone = '',
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/orders'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'listing_id': listingId,
            'quantity': quantity,
            'shipping_name': shippingName,
            'shipping_address': shippingAddress,
            'shipping_phone': shippingPhone,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to create order: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<Order> payOrder(String orderId, String paymentMethod) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/pay'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({'payment_method': paymentMethod}),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to pay order: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<Order> requestRelease(String orderId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/request-release'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to request release: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Withdraws the seller's whole released balance to a bank account.
  /// Only files a request for the admin to approve; returns the amount asked for.
  static Future<double> requestPayout({
    required String bankName,
    required String accountHolder,
    required String accountNumber,
  }) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/orders/request-payout'),
          headers: {..._authHeaders, 'Content-Type': 'application/json'},
          body: jsonEncode({
            'bank_name': bankName,
            'account_holder': accountHolder,
            'account_number': accountNumber,
          }),
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to request payout: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return (json['amount'] as num).toDouble();
  }

  static Future<Order> _postPhotos(
    String path,
    Map<String, String> fields,
    String photoPath,
  ) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}$path'),
    );
    request.headers.addAll(_authHeaders);
    request.fields.addAll(fields);
    final mimeType = lookupMimeType(photoPath) ?? 'image/jpeg';
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        photoPath,
        contentType: MediaType.parse(mimeType),
      ),
    );
    final streamed = await request.send().timeout(const Duration(seconds: 30));
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Seller handing the parcel to a courier, with a photo of it and the
  /// tracking number (`POST /orders/{id}/ship`).
  static Future<Order> shipOrder({
    required String orderId,
    required String courier,
    required String trackingNumber,
    required String photoPath,
  }) => _postPhotos('/orders/$orderId/ship', {
    'courier': courier,
    'tracking_number': trackingNumber,
  }, photoPath);

  /// Seller uploading proof of delivery — starts the buyer's review timer
  /// (`POST /orders/{id}/deliver`).
  static Future<Order> markDelivered({
    required String orderId,
    required String photoPath,
  }) => _postPhotos('/orders/$orderId/deliver', {}, photoPath);

  static Future<Order> confirmOrder(String orderId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/confirm'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to confirm order: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Buyer confirming receipt of the order, releasing the held funds to the
  /// seller (`POST /orders/{id}/release`).
  static Future<Order> releaseOrder(String orderId) async {
    final response = await http
        .post(
          Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/release'),
          headers: _authHeaders,
        )
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('Failed to confirm receipt: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Buyer rating + reviewing a completed order (`POST /orders/{id}/review`)
  /// — multipart so the review's photos can ride along with the rating and
  /// comment in one request. Returns the order with the new review embedded
  /// so the caller can refresh its screen straight from the response.
  static Future<Order> submitReview({
    required String orderId,
    required int rating,
    required String comment,
    List<String> photoPaths = const [],
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/review'),
    );
    request.headers.addAll(_authHeaders);
    request.fields['rating'] = '$rating';
    request.fields['comment'] = comment;
    for (final path in photoPaths) {
      final mimeType = lookupMimeType(path) ?? 'application/octet-stream';
      request.files.add(
        await http.MultipartFile.fromPath(
          'photos',
          path,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw Exception('Failed to submit review: ${response.body}');
    }

    return Order.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
