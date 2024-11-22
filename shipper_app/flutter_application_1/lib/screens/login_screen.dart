import 'package:flutter/material.dart';
import '../screens/manage_delivery_page.dart'; // Import màn hình ManageDeliveryPage
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? loginError;

  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        loginError = "Email và mật khẩu không được để trống.";
      });
      return;
    }

    try {
      // Gửi yêu cầu đến API
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/users/login'), // Thay localhost bằng địa chỉ IP
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Xử lý phản hồi thành công
        final data = jsonDecode(response.body);
        final token = data['accessToken'];
        final user = data['user'];

        print("Token: $token");
        print("User: ${user['name']} - Role: ${user['role']}");

        if (user['role'] == 'shipper') {
          // Chuyển sang màn hình Manage Delivery
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ManageDeliveryPage(token: token), // Truyền token sang màn hình mới
            ),
          );
        } else {
          setState(() {
            loginError = "Bạn không phải shipper.";
          });
        }
      } else {
        // Xử lý lỗi từ server
        final data = jsonDecode(response.body);
        setState(() {
          loginError = data['message'] ?? "Đăng nhập thất bại.";
        });
      }
    } catch (error) {
      // Xử lý lỗi kết nối hoặc lỗi không mong muốn
      print("Error during login: $error");
      setState(() {
        loginError = "Không thể kết nối đến server. Vui lòng kiểm tra lại.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Shipper Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  if (loginError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        loginError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Login",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
