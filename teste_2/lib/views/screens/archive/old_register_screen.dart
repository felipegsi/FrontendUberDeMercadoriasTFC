import 'package:flutter/material.dart';
import 'package:teste_2/views/screens/archive/main_screen.dart';
import '../../../models/client.dart';
import '../../../services/network_service.dart';
import '../../../widgets/custom_button.dart';
import 'old_login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _taxPayerNumberController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Name')),
            TextField(controller: _emailController, decoration: InputDecoration(hintText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(hintText: 'Password'), obscureText: true),
            TextField(controller: _phoneNumberController, decoration: InputDecoration(hintText: 'Phone Number')),
            TextField(controller: _taxPayerNumberController, decoration: InputDecoration(hintText: 'Tax Payer Number'), keyboardType: TextInputType.number),
            TextField(controller: _streetController, decoration: InputDecoration(hintText: 'Street')),
            TextField(controller: _cityController, decoration: InputDecoration(hintText: 'City')),
            TextField(controller: _postalCodeController, decoration: InputDecoration(hintText: 'Postal Code'), keyboardType: TextInputType.number),
            CustomButton(text: 'Register', onPressed: () async {
              final client = Client(
                name: _nameController.text,
                email: _emailController.text,
                password: _passwordController.text,
                phoneNumber: _phoneNumberController.text,
                taxPayerNumber: int.tryParse(_taxPayerNumberController.text) ?? 0,
                street: _streetController.text,
                city: _cityController.text,
                postalCode: int.tryParse(_postalCodeController.text) ?? 0,
              );

              final networkService = NetworkService();
              bool registrationSuccess = await networkService.registerClient(client.toJson());

              if (registrationSuccess) {
                // Navegar para a tela de login em caso de sucesso
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MainScreen()),
                );
              } else {
                // Mostrar uma mensagem de erro se o registro falhar
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Registration Failed'),
                    content: Text('Failed to register. Please try again.'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Fecha o diálogo
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            }),

          ],
        ),
      ),
    );
  }
}
