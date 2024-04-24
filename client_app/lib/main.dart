import 'package:flutter/material.dart';
import 'package:teste_2/views/screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //theme: ,
      //darkTheme: ,
      home: SplashScreen(),
    );
  }
}
