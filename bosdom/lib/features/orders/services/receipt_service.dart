import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../../profile/models/seller_order.dart';
import '../models/order.dart';

abstract final class ReceiptService {
  static Future<Uint8List> generateSellerReceiptPdf(SellerOrder order) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/receipts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': order.id,
        'date': order.date,
        'items': [
          {
            'name': order.productName,
            'qty_label':
                'Qty: ${order.quantityLabel} × '
                '\$${order.unitPrice.toStringAsFixed(2)}',
            'line_total': order.total,
          },
        ],
        'shipping_name': order.buyerName,
        'shipping_address': order.buyerAddress,
        'shipping_phone': order.buyerPhone,
        'delivery_method': order.deliveryMethod,
        'subtotal': order.total,
        'discount': order.platformFee,
        'discount_label':
            'Platform Fee (${(kSellerPlatformFeeRate * 100).round()}%)',
        'shipping_fee': order.shippingFee,
        'shipping_fee_label': order.shippingFeeLabel,
        'total': order.earnings,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate receipt: ${response.body}');
    }

    return response.bodyBytes;
  }

  static Future<Uint8List> generateReceiptPdf(Order order) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/receipts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': order.id,
        'date': order.dateLabel,
        'items': [
          {
            'name': order.productName,
            'qty_label':
                'Qty: ${order.quantity} × '
                '\$${order.unitPrice.toStringAsFixed(2)}',
            'line_total': order.totalAmount,
          },
        ],
        'shipping_name': order.shippingName,
        'shipping_address': order.shippingAddress,
        'shipping_phone': order.shippingPhone,
        'subtotal': order.totalAmount,
        'total': order.totalAmount,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate receipt: ${response.body}');
    }

    return response.bodyBytes;
  }
}
