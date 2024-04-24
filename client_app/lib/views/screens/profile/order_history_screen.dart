import 'package:flutter/material.dart';
import '../../../models/order.dart';
import '../../../services/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  Future<List<Order>>? _orderHistory;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      setState(() {
        _orderHistory = NetworkService().getOrderHistory();
      });
    } else {
      // Se não houver token, redirecione para a tela de login ou mostre um erro
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: FutureBuilder<List<Order>>(
        future: _orderHistory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No orders found.'));
          } else {
            List<Order> orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                Order order = orders[index];
                return Card(
                  child: ListTile(
                    title: Text('Order'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From ${order.origin} to ${order.destination}'),
                        Text('Category: ${order.category}'),
                        Text('Width: ${order.width}'),
                        Text('Height: ${order.height}'),
                        Text('Length: ${order.length}'),
                        Text('Weight: ${order.weight}'),
                        if (order.value != null) Text('Value: ${order.value}'),
                        if (order.status != null) Text('Status: ${order.status}'),
                        if (order.data != null) Text('Date: ${order.data}'),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}