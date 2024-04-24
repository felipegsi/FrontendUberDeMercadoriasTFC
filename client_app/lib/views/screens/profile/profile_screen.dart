import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../models/client.dart';
import '../../../services/network_service.dart';
import '../../../themes/app_theme.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final NetworkService _networkService = NetworkService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Container(
        color: Colors.white, // Define a cor de fundo como branco
        child: FutureBuilder<Client?>(
        future: _networkService.viewProfile(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred'));
          } else if (snapshot.data == null) {
            return Center(child: Text('No profile data available'));
          } else {
            return Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50, // Define o raio do CircleAvatar
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Substitua 'photoUrl' pela URL da foto do usuário
                  ),
                  SizedBox(height: 20),
                  Card(
                    color: cardBackgroundColor, // Define a cor de fundo como grey
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.person),
                          title: Text('Name'),
                          subtitle: Text('${snapshot.data!.name}'),
                        ),
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text('Email'),
                          subtitle: Text('${snapshot.data!.email}'),
                        ),
                        ListTile(
                          leading: Icon(Icons.phone),
                          title: Text('Phone Number'),
                          subtitle: Text('${snapshot.data!.phoneNumber}'),
                        ),
                        ListTile(
                          leading: Icon(Icons.location_city),
                          title: Text('City'),
                          subtitle: Text('${snapshot.data!.city}'),
                        ),
                        ListTile(
                          leading: Icon(Icons.logout),
                          title: Text('Logout'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: const Text(
                                    'Do you sure want to sing out?',
                                    style: TextStyle(fontSize: 20),
                                    // Aumenta o tamanho da fonte
                                    textAlign: TextAlign
                                        .center, // Centraliza o texto na linha
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 100,
                                          // Define a largura do botão
                                          child: TextButton(
                                            child: Text('No'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: textColor,
                                              backgroundColor:
                                                  iconBackgroundColor, // Define a cor de fundo como vermelho
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Fecha o diálogo
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        // Adiciona um espaço de 10 pixels

                                        Container(
                                          width: 100,
                                          // Define a largura do botão
                                          child: TextButton(
                                            child: Text('Yes'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors
                                                  .red, // Define a cor de fundo como vermelho
                                            ),
                                            onPressed: () async {
                                              await _networkService.logout();
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              LoginScreen()));
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete Account'),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: const Text(
                                    'Do you sure want to sing out?',
                                    style: TextStyle(fontSize: 20),
                                    // Aumenta o tamanho da fonte
                                    textAlign: TextAlign
                                        .center, // Centraliza o texto na linha
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 100,
                                          // Define a largura do botão
                                          child: TextButton(
                                            child: Text('No'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: textColor,
                                              backgroundColor:
                                                  iconBackgroundColor, // Define a cor de fundo como vermelho
                                            ),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Fecha o diálogo
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        // Adiciona um espaço de 10 pixels
                                        Container(
                                          width: 100,
                                          // Define a largura do botão
                                          child: TextButton(
                                            child: Text('Yes'),
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.white,
                                              backgroundColor: Colors
                                                  .red, // Define a cor de fundo como vermelho
                                            ),
                                            onPressed: () async {
                                              await _networkService
                                                  .deleteAccount(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    ),
    );
  }
}
