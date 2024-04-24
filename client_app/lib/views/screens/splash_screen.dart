import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:teste_2/views/screens/home/home_screen.dart';
import '../../services/network_service.dart';
import 'auth/login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkIsValidToken();
  }

  Future<void> _checkIsValidToken() async {
    final networkService = NetworkService();
    bool isValid = await networkService.isValidToken();

    Timer(Duration(seconds: 3), () {
      if (isValid) {// se o token for válido redireciona para a HomeScreen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
      } else {// se o token não for válido redireciona para a LoginScreen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SvgPicture.asset('assets/images/logo-svg.svg'),
      ),
    );
  }
}