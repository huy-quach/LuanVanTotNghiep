import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrderService {
  final String baseUrl = 'http://localhost:5000/api/orders'; // Thay localhost bằng IP backend của bạn

  /// **Fetch all orders**
  Future<List<Order>> fetchOrders(String token) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching orders: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching orders: $error');
  }
}


  /// **Search orders by phone**
  Future<List<Order>> searchOrders(String token, {String? phoneNumber}) async {
    try {
      Uri url = Uri.parse('$baseUrl/search?phoneNumber=$phoneNumber');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((order) => Order.fromJson(order)).toList();
      } else {
        throw Exception('Error searching orders: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error searching orders: $error');
    }
  }

  /// **Update order status**
  Future<void> updateOrderStatus(String token, String orderId, String newStatus) async {
    try {
      final url = Uri.parse('$baseUrl/$orderId/shipper-status');
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'orderStatus': newStatus}),
      );

      if (response.statusCode != 200) {
        throw Exception('Error updating order status: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error updating order status: $error');
    }
  }

  /// **Cancel order**
  Future<void> cancelOrder(String token, String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/$orderId/cancel');
      final response = await http.patch(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Error canceling order: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error canceling order: $error');
    }
  }
}
