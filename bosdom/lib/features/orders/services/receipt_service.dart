import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../../core/config/api_config.dart';
import '../models/order.dart';

abstract final class ReceiptService {
  static Future<Uint8List> generateReceiptPdf(Order order) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/receipts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'order_id': order.displayNumber,
        'date': order.dateLabel,
        'seller_name': order.sellerName,
        'seller_logo_url': order.sellerLogoUrl,
        'items': [
          {
            'name': order.productName,
            'qty_label':
                'Qty: ${order.quantity} × '
                '\$${order.unitPrice.toStringAsFixed(2)}',
            'line_total': order.totalAmount,
            'image_url': order.imageUrl,
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
