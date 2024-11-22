import 'product_item.dart';

class Order {
  final String id;
  final String fullName;
  final String phoneNumber;
  final double totalAmount;
  final String orderStatus;
  final List<ProductItem> products;

  Order({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.totalAmount,
    required this.orderStatus,
    required this.products,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      fullName: json['shippingAddress']['fullName'] ?? '',
      phoneNumber: json['shippingAddress']['phoneNumber'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderStatus: json['orderStatus'] ?? '',
      products: (json['products'] as List<dynamic>)
          .map((item) => ProductItem.fromJson(item))
          .toList(),
    );
  }

  /// **Phương thức `copyWith`**
  Order copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    double? totalAmount,
    String? orderStatus,
    List<ProductItem>? products,
  }) {
    return Order(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      orderStatus: orderStatus ?? this.orderStatus,
      products: products ?? this.products,
    );
  }
}
