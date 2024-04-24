import 'package:flutter/material.dart';
import 'package:teste_2/views/screens/archive/main_screen.dart';
import '../../../services/network_service.dart';
import '../../../widgets/custom_button.dart';
import '../profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class OldLoginScreen extends StatefulWidget {
  @override
  _OldLoginScreenState createState() => _OldLoginScreenState();
}

class _OldLoginScreenState extends State<OldLoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(hintText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(hintText: 'Password'), obscureText: true),
            CustomButton(text: 'Login', onPressed: () async {
              final networkService = NetworkService();
              String? token = await networkService.login(_emailController.text, _passwordController.text);
              if (token != null) {
                // Save the token in SharedPreferences
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('token', token);

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              } else {
                // Show login error
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to login. Please try again.'),
                      actions: [
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}