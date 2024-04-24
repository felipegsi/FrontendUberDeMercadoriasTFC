// Importações necessárias para o funcionamento do aplicativo.
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_route_service/open_route_service.dart';

// Declaração da classe do widget MapScreen, que é um StatefulWidget, permitindo atualizações de estado.
class Copy extends StatefulWidget {
  const Copy({super.key});

  @override
  State<Copy> createState() => _Copy();
}

// Estado associado ao MapScreen. Mantém os dados necessários e a lógica para o funcionamento do mapa.
class _Copy extends State<Copy> {
  // Ponto inicial no mapa, utilizado para centrar o mapa na inicialização.
  late LatLng myPoint;
  // Controle de estado para mostrar ou ocultar a animação de carregamento.
  bool isLoading = false;

  @override
  void initState() {
    // Define o ponto inicial e chama o initState da superclasse.
    myPoint = defaultPoint;
    super.initState();
  }

  // Ponto padrão para inicializar o mapa, neste caso, coordenadas em Lisboa, Portugal.
  final defaultPoint = const LatLng(38.758072, -9.153414);

  // Listas para armazenar pontos de rotas, marcadores e a própria rota.
  List listOfPoints = [];
  List<LatLng> points = [];
  List<Marker> markers = [];

  // Função assíncrona para obter as coordenadas de rota entre dois pontos usando a OpenRouteService API.
  Future<void> getCoordinates(LatLng lat1, LatLng lat2) async {
    setState(() {
      isLoading = true;
    });

    // Cliente da OpenRouteService API com chave de API fornecida.
    final OpenRouteService client = OpenRouteService(
      apiKey: '5b3ce3597851110001cf6248b8fc3d76941643ee9de00a23820316b7',
    );

    // Perfil de roteamento definido para carros.
    ORSProfile profile = ORSProfile.drivingCar;

    // Solicitação de rota entre os dois pontos especificados.
    final List<ORSCoordinate> routeCoordinates = await client.directionsRouteCoordsGet(
      startCoordinate: ORSCoordinate(latitude: lat1.latitude, longitude: lat1.longitude),
      endCoordinate: ORSCoordinate(latitude: lat2.latitude, longitude: lat2.longitude),
      profileOverride: profile,
    );

    // Conversão das coordenadas da rota para o tipo LatLng e atualização do estado.
    final List<LatLng> routePoints = routeCoordinates.map((coordinate) => LatLng(coordinate.latitude, coordinate.longitude)).toList();

    setState(() {
      points = routePoints;
      isLoading = false;
    });
  }

  // Controlador do mapa para manipulação programática.
  final MapController mapController = MapController();

  // Função para manipular toques no mapa, adicionando marcadores ou calculando rotas.
  void _handleTap(LatLng latLng) {
    setState(() {
      // Adiciona marcadores até o máximo de dois.
      if (markers.length < 2) {
        markers.add(
          Marker(
            point: latLng,
            width: 80,
            height: 80,
            child: Draggable(
              feedback: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.location_on),
                color: Colors.black,
                iconSize: 45,
              ),
              onDragEnd: (details) {
                // Debugging: imprime a localização do marcador solto.
                setState(() {
                  print("Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}");
                });
              },
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.location_on),
                color: Colors.black,
                iconSize: 45,
              ),
            ),
          ),
        );
      }

      // Ajusta o zoom e centraliza o mapa no marcador adicionado se apenas um marcador foi colocado.
      if (markers.length == 1) {
        double zoomLevel = 16.5;
        mapController.move(latLng, zoomLevel);
      }

      // Se dois marcadores foram colocados, calcula a rota entre eles.
      if (markers.length == 2) {
        Future.delayed(const Duration(milliseconds: 1), () {
          setState(() {
            isLoading = true;
          });
        });

        getCoordinates(markers[0].point, markers[1].point);

        // Ajusta o mapa para mostrar ambos os marcadores.
        LatLngBounds bounds = LatLngBounds.fromPoints(markers.map((marker) => marker.point).toList());
        mapController.fitBounds(bounds, options: FitBoundsOptions(padding: EdgeInsets.all(50.0)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Construção do layout do mapa com marcadores, rota e um indicador de carregamento.
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialZoom: 16,
              initialCenter: myPoint,
              onTap: (tapPosition, latLng) => _handleTap(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
              ),
              MarkerLayer(markers: markers),
              PolylineLayer(
                polylineCulling: false,
                polylines: [
                  Polyline(points: points, color: Colors.black, strokeWidth: 5),
                ],
              ),
            ],
          ),
          // Exibe um indicador de carregamento enquanto a rota está sendo calculada.
          Visibility(
            visible: isLoading,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
          ),
          // Botão para adicionar marcadores ou limpar a rota existente.
          Positioned(
            top: MediaQuery.of(context).padding.top + 20.0,
            left: MediaQuery.of(context).size.width / 2 - 110,
            child: Align(
              child: TextButton(
                onPressed: () {
                  if (markers.isEmpty) {
                    print('Mark points in map');
                  } else {
                    setState(() {
                      markers = [];
                      points = [];
                    });
                  }
                },
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
                  child: Center(
                    child: Text(
                      markers.isEmpty ? "Mark route in map" : "Clean route",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // Botões de zoom para aumentar ou diminuir a visualização do mapa.
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              mapController.move(mapController.camera.center, mapController.camera.zoom + 1);
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            backgroundColor: Colors.black,
            onPressed: () {
              mapController.move(mapController.camera.center, mapController.camera.zoom - 1);
            },
            child: const Icon(Icons.remove, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

