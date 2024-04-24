import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:teste_2/views/screens/home/search_route_drawer.dart';
import 'package:teste_2/views/screens/home/menu_drawer.dart';

import '../../../themes/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final defaultPoint = const LatLng(38.758072, -9.153414);
  int _selectedIndex = 0;
  double _backgroundIconSize = 60;
  double _iconSize = 30;
  double _spaceBetweenIcons = 30;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();  //preciso disso para abrir o drawer


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawerEnableOpenDragGesture: false,  // This!

      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialZoom: 16,
              initialCenter: defaultPoint,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
            ],
          ),
          Positioned(
            top: 35, // Posiciona o FloatingActionButton no topo da tela
            left: 15, // Posiciona o FloatingActionButton à esquerda da tela
            child: FloatingActionButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),//abre o drawer
              backgroundColor: backgroundColor, // Define a cor de fundo como branco
              child: const Icon(Icons.menu, color: iconColor),
            ),

          ),



          Positioned(
            bottom: 35, // Posiciona o Card na parte inferior da tela
            left: 0,
            right: 0,
            child: Container(
              height: 130, // Define a altura do Card
              child: Card(
                // Substitui o Container por um Card
                margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width *
                        0.05), // Define a margem como 5% da largura da tela
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      30), // Adiciona bordas arredondadas ao Card
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true, // Define que o BottomSheet pode ser rolado
                            builder: (context) => FractionallySizedBox(
                              heightFactor: 0.95, // Define a altura do Drawer como 60% da altura total da tela
                              child: SearchRoute(),
                            ),
                          );
                        },
                        child: Container(
                          height: 40,
                          width: double.infinity,
                          child: Stack(
                            children: [
                              TextField(
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Where to?',
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: iconColor,
                                  ),
                                  filled: true,
                                  fillColor: iconBackgroundColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 5,
                                // Alinha o botão à direita
                                top: 5,
                                // Posiciona no topo com 5 pixels de espaçamento para centralizar verticalmente
                                bottom: 5,
                                // Posiciona na base com 5 pixels de espaçamento para centralizar verticalmente
                                left: 220,
                                // ajusta o left para que seja responsivo

                                child: ElevatedButton(
                                  onPressed: () {
                                    // Handle button press here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 5.0),
                                    // Padding interno do botão
                                    shape:
                                        StadiumBorder(), // Forma com bordas arredondadas longas, similar a um estádio
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    // Garante que o Row não se expanda mais do que o necessário
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        size: 16,
                                        color: iconColor,
                                      ),
                                      // Ícone similar ao mostrado na imagem
                                      SizedBox(width: 10),
                                      // Espaço entre o ícone e o texto
                                      Text('Now',
                                          style: TextStyle(color: textColor)),
                                      SizedBox(width: 2),
                                      // Texto do botão
                                      Icon(Icons.arrow_drop_down,
                                          size: 18, color: iconColor),
                                      // Ícone de seta para baixo
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: kToolbarHeight,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          // Define a direção do scroll como horizontal
                          children: [
                            Container(
                              width: _backgroundIconSize,
                              // Define a largura do Container como um quarto da largura da tela
                              decoration: BoxDecoration(
                                color: iconBackgroundColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                iconSize: _iconSize,
                                icon: Icon(Icons.history),
                                color: iconColor,
                                onPressed: () {
                                  _onItemTapped(0);
                                },
                              ),
                            ),
                            SizedBox(width: _spaceBetweenIcons),
                            // Adiciona um espaço de 10 pixels
                            Container(
                              width: _backgroundIconSize,
                              // Define a largura do Container como um quarto da largura da tela
                              decoration: BoxDecoration(
                                color: iconBackgroundColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                iconSize: _iconSize,
                                icon: Icon(Icons.star),
                                color: iconColor,
                                onPressed: () {
                                  _onItemTapped(0);
                                },
                              ),
                            ),
                            SizedBox(width: _spaceBetweenIcons),
                            // Adiciona um espaço de 10 pixels
                            Container(
                              width: _backgroundIconSize,
                              // Define a largura do Container como um quarto da largura da tela
                              decoration: BoxDecoration(
                                color: iconBackgroundColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                iconSize: _iconSize,
                                icon: Icon(Icons.notifications),
                                color: iconColor,
                                onPressed: () {
                                  _onItemTapped(1);
                                },
                              ),
                            ),
                            SizedBox(width: _spaceBetweenIcons),
                            // Adiciona um espaço de 10 pixels
                            Container(
                              width: _backgroundIconSize,
                              // Define a largura do Container como um quarto da largura da tela
                              decoration: BoxDecoration(
                                color: iconBackgroundColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                iconSize: _iconSize,
                                icon: Icon(Icons.person),
                                color: iconColor,
                                onPressed: () {
                                  _onItemTapped(2);
                                },
                              ),
                            ),
                            SizedBox(width: _spaceBetweenIcons),
                            // Adiciona um espaço de 10 pixels
                            Container(
                              width: _backgroundIconSize,
                              // Define a largura do Container como um quarto da largura da tela
                              decoration: BoxDecoration(
                                color: iconBackgroundColor,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: IconButton(
                                iconSize: _iconSize,
                                icon: Icon(Icons.help_outline),
                                color: iconColor,
                                onPressed: () {
                                  _onItemTapped(3);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const MenuDrawer(), // Adiciona o CustomDrawer ao Scaffold

    );
  }
}
