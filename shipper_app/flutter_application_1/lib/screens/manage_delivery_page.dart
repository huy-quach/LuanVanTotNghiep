import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import 'package:intl/intl.dart';

class ManageDeliveryPage extends StatefulWidget {
  final String token;

  ManageDeliveryPage({required this.token});

  @override
  _ManageDeliveryPageState createState() => _ManageDeliveryPageState();
}

class _ManageDeliveryPageState extends State<ManageDeliveryPage> {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  final OrderService orderService = OrderService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrdersData();
  }

  Future<void> fetchOrdersData() async {
    try {
      final fetchedOrders = await orderService.fetchOrders(widget.token);
      setState(() {
        orders = fetchedOrders;
        filteredOrders = fetchedOrders;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching orders: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await orderService.updateOrderStatus(widget.token, orderId, newStatus);
      setState(() {
        orders = orders.map((order) {
          if (order.id == orderId) {
            return order.copyWith(orderStatus: newStatus);
          }
          return order;
        }).toList();
        filteredOrders = orders;
      });
    } catch (error) {
      print('Error updating order status: $error');
    }
  }

  Future<void> cancelOrder(String orderId) async {
    try {
      await orderService.cancelOrder(widget.token, orderId);
      setState(() {
        orders = orders.map((order) {
          if (order.id == orderId) {
            return order.copyWith(orderStatus: 'Hủy bỏ');
          }
          return order;
        }).toList();
        filteredOrders = orders;
      });
    } catch (error) {
      print('Error canceling order: $error');
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Đang vận chuyển':
        return Colors.orange;
      case 'Hoàn thành':
        return Colors.green;
      case 'Hủy bỏ':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

Widget buildOrderCard(Order order) {
  final NumberFormat currencyFormat = NumberFormat("#,##0", "vi_VN");

  return Card(
    elevation: 5,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.fullName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              Chip(
                label: Text(
                  order.orderStatus.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: getStatusColor(order.orderStatus),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'SĐT: ${order.phoneNumber}',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          SizedBox(height: 8),
          Text(
            'Tổng tiền: ${currencyFormat.format(order.totalAmount)} VND',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Divider(color: Colors.grey),
          Text(
            'Chi tiết sản phẩm:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...order.products.map((product) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${product.name} - Số lượng: ${product.quantity}',
                  style: TextStyle(fontSize: 14),
                ),
              )),
          SizedBox(height: 16),
          if (order.orderStatus == 'Đang vận chuyển')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await updateOrderStatus(order.id, 'Hoàn thành');
                  },
                  icon: Icon(Icons.check),
                  label: Text('Hoàn thành'),
                ),
                SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    await cancelOrder(order.id);
                  },
                  icon: Icon(Icons.close),
                  label: Text('Hủy bỏ'),
                ),
              ],
            ),
        ],
      ),
    ),
  );
}




  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          labelText: 'Tìm kiếm theo số điện thoại',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
        onChanged: (value) async {
          if (value.trim().isEmpty) {
            setState(() {
              filteredOrders = orders;
            });
          } else {
            try {
              filteredOrders = await orderService.searchOrders(
                widget.token,
                phoneNumber: value.trim(),
              );
              setState(() {});
            } catch (error) {
              print('Error searching orders: $error');
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản lý giao hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrdersData, // Kéo xuống để làm mới danh sách đơn hàng
        child: Column(
          children: [
            buildSearchBar(),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return buildOrderCard(filteredOrders[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
