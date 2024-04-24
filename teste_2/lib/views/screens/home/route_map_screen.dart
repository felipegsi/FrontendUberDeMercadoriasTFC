import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:teste_2/views/screens/home/check_measures.dart';

import '../../../models/location.dart';
import '../../../services/network_service.dart';

// Define uma tela de mapa para exibir rotas entre dois pontos geográficos.
class RouteMapScreen extends StatefulWidget {
  final LatLng origin; // Coordenada de origem para a rota.
  final LatLng destination; // Coordenada de destino para a rota.

  // Construtor da classe com as coordenadas de origem e destino necessárias.
  const RouteMapScreen(
      {Key? key, required this.origin, required this.destination})
      : super(key: key);

  @override
  _RouteMapScreenState createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final NetworkService _networkService = NetworkService();
  late String transportType; // Define o tipo de transporte como 'Small'.

  late Location location = Location(
    // Define a origem como uma string de coordenadas.
    origin: '${widget.origin.latitude},${widget.origin.longitude}',
    // Define o destino como uma string de coordenadas.
    destination:
        '${widget.destination.latitude},${widget.destination.longitude}',
  );

  // Lista para armazenar os custos de cada categoria de pedido
  List<Decimal> ordersCosts = [];

  // Lista para armazenar pontos da rota.
  List<LatLng> points = [];

  // Lista para armazenar marcadores no mapa. Controlador para manipulações programáticas do mapa.
  List<Marker> markers = [];

  final MapController mapController = MapController();

  bool isLoading =
      false; // Indicador de estado de carregamento para controle UI.

  @override
  void initState() {
    super.initState();

    // Adiciona marcadores no mapa para os pontos de origem e destino ao iniciar o widget.
    markers.add(
      Marker(
        point: widget.origin,
        // Marcador vermelho para a origem.
        child: Icon(Icons.location_on, color: Colors.red),
      ),
    );
    markers.add(
      Marker(
        point: widget.destination,
        // Marcador azul para o destino.
        child: Icon(Icons.location_on, color: Colors.blue),
      ),
    );
    // Inicia a obtenção da rota entre origem e destino.
    getRoute();
  }

  // Função assíncrona para calcular a rota entre dois pontos usando OpenRouteService API.
  Future<void> getRoute() async {
    setState(() {
      isLoading = true; // Ativa o indicador de carregamento.
    });

    // Cria uma instância do cliente da OpenRouteService com uma chave API.
    final OpenRouteService client = OpenRouteService(
      apiKey: '5b3ce3597851110001cf6248b8fc3d76941643ee9de00a23820316b7',
    );

    // Realiza a solicitação para obter as coordenadas da rota entre os pontos definidos.
    final List<ORSCoordinate> routeCoordinates =
        await client.directionsRouteCoordsGet(
      startCoordinate: ORSCoordinate(
          latitude: widget.origin.latitude, longitude: widget.origin.longitude),
      endCoordinate: ORSCoordinate(
          latitude: widget.destination.latitude,
          longitude: widget.destination.longitude),
      profileOverride: ORSProfile.drivingCar,
    );

    // Atualiza o estado com os pontos da rota e desativa o indicador de carregamento.
    setState(() {
      points = routeCoordinates
          .map((coord) => LatLng(coord.latitude, coord.longitude))
          .toList();
      isLoading = false;
      // Ajusta o mapa para incluir ambos os marcadores com um zoom adequado.
      if (markers.length == 2) {
        LatLngBounds bounds =
            LatLngBounds.fromPoints([widget.origin, widget.destination]);
        mapController.fitBounds(bounds,
            options: FitBoundsOptions(padding: EdgeInsets.all(50.0)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Constrói a interface do usuário do mapa com camadas de mapa, marcadores e rotas.
    return Scaffold(
      appBar: AppBar(
        title: Text('Map Screen'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: widget.origin, // Define o centro inicial do mapa.
              initialZoom: 13.0, // Define o zoom inicial do mapa.
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'YourAppName/1.0',
              ),
              MarkerLayer(markers: markers),
              PolylineLayer(polylines: [
                Polyline(points: points, strokeWidth: 4.0, color: Colors.blue),
              ]),
            ],
          ),
          // Mostra um indicador de progresso enquanto a rota está sendo carregada.
          if (isLoading) Center(child: CircularProgressIndicator()),
          // Adiciona o menu sobre o mapa.
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.symmetric(vertical: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 1.0,
                    offset: Offset(0.0, 0.0),
                  ),
                ],
              ),
              child: FutureBuilder<List<Decimal>>(
                future: _networkService.estimateAllCategoryOrderCost(location),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Decimal>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    print(location.destination);
                    return Text('Error: ${snapshot.error}');
                  } else {
                    ordersCosts = snapshot.data!;

                    return ListView(
                      shrinkWrap: true,
                      // Para garantir que o ListView ocupe apenas o espaço necessário.
                      children: [
                        _buildMenuItem(
                            context,
                            'Small',
                            'Canetas, cartas, smartphone',
                            '€${ordersCosts[0]}',
                            FontAwesomeIcons.motorcycle),
                        _buildMenuItem(
                            context,
                            'Medium',
                            'Micro-ondas, ventilador, panela',
                            '€${ordersCosts[1]}',
                            FontAwesomeIcons.car),
                        _buildMenuItem(
                            context,
                            'Large',
                            'Frigorífico, fogão, cama',
                            '€${ordersCosts[2]}',
                            FontAwesomeIcons.truck),
                        _buildMenuItem(
                            context,
                            'Motorized',
                            'Carro, empilhador, carcaça',
                            '€${ordersCosts[3]}',
                            FontAwesomeIcons.trailer),

                        // Adicione mais itens conforme necessário.
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

// Função auxiliar para construir um item do menu. +++ adicionar mais um parametro "context" do builder para saber qual pagina ira mandar
  Widget _buildMenuItem(BuildContext context, String category, String example,
      String price, IconData icon) {
    return ListTile(
      leading: Icon(icon, size: 34.0),
      // Define o ícone à esquerda.
      title: Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
      // O título do item.
      subtitle: Text(example),
      // O subtítulo do item.
      trailing: Text(price,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      // O preço à direita.
      onTap: () {
        //tirar o if e enviar para uma unica pagina que possui um parametro que ira definir qual categoria ira ser mostrada
        /* if(category == 'Small'){
          Navigator.of(context).pushNamed('/small');
        } else if(category == 'Medium'){
          Navigator.of(context).pushNamed('/medium');
        } else if(category == 'Large'){
          Navigator.of(context).pushNamed('/large');
        } else if(category == 'Motorized'){
          Navigator.of(context).pushNamed('/motorized');
        }*/
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CheckMeasures(
              /*
              *  // tipo de transporte, SMALL, MEDIUM, LARGE
  final String transportType;
  final LatLng origin;
  final LatLng destination;
              * */
              categoryType: category,
              origin: widget.origin,
              destination: widget.destination,
            ),
          ),
        );
        // Adicione ação ao tocar no item, se necessário.
      },
    );
  }
}
