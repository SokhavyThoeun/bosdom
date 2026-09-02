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
        'order_id': order.id,
        'date': order.date,
        'items': [
          for (final item in order.items)
            {
              'name': item.product.name,
              'qty_label': item.qtyLabel,
              'line_total': item.lineTotal,
            },
        ],
        'shipping_name': order.shippingName,
        'shipping_address': order.shippingAddress,
        'shipping_phone': order.shippingPhone,
        'delivery_method': order.deliveryMethod,
        'subtotal': order.subtotal,
        'discount': order.discount,
        'shipping_fee': order.shippingFee,
        'shipping_fee_label': order.shippingFeeLabel,
        'total': order.total,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to generate receipt: ${response.body}');
    }

    return response.bodyBytes;
  }
}
