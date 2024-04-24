import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teste_2/views/screens/home/home_screen.dart';
import 'package:teste_2/views/screens/archive/old_login_screen.dart';
import 'package:teste_2/views/screens/archive/map_screen_copy.dart';
import 'package:teste_2/views/screens/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:teste_2/views/screens/archive/old_register_screen.dart';

import 'estimate_order_costs_screen.dart';
import '../profile/order_history_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Índice da aba atual
  String? _token;

  @override
  void initState() {
    super.initState();
    _retrieveToken();
  }

  Future<void> _retrieveToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
  }

  static List<Widget> _widgetOptions(String? token) => <Widget>[
    HomeScreen(),
    EstimateOrderCostScreen(), // Pass the token to EstimateOrderCostScreen
    ProfileScreen(),
    OrderHistoryScreen(), // Pass the token to OrderHistoryScreen
    OldLoginScreen(),
    RegisterScreen(),
    MapScreenCopy(),

  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions(_token).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_shopping_cart),
            label: 'Estimate Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Order History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login),
            label: 'Login(teste)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            label: 'Register(teste)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
      ),
    );
  }
}