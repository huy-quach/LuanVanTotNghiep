class ProductItem {
  final String name;
  final int quantity;

  ProductItem({
    required this.name,
    required this.quantity,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) {
  return ProductItem(
    name: json['product']['name'] ?? 'Tên không xác định',
    quantity: json['quantity'] ?? 0,
  );
}

}
