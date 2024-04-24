import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:teste_2/services/network_service.dart';

import '../../../models/order.dart';
import 'order_cost_screen.dart';

class CheckMeasures extends StatefulWidget {
  // tipo de transporte, SMALL, MEDIUM, LARGE
  final String categoryType;
  final LatLng origin;
  final LatLng destination;

  // Construtor para inicializar o tipo de transporte
  const CheckMeasures(
      {Key? key,
      required this.categoryType,
      required this.origin,
      required this.destination})
      : super(key: key);

  @override
  _CheckMeasuresState createState() => _CheckMeasuresState();
}

// Estado associado ao CheckMeasures
class _CheckMeasuresState extends State<CheckMeasures> {
  // Controladores de texto para capturar as entradas do usuário
  final TextEditingController _width = TextEditingController();
  final TextEditingController _height = TextEditingController();
  final TextEditingController _length = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final NetworkService networkService = NetworkService();

  // Chave global para identificar o formulário e para validação
  final _formKey = GlobalKey<FormState>();



  File? _image; // Variável para armazenar a imagem escolhida

  final ImagePicker _picker = ImagePicker();

  // Método para lidar com a escolha da imagem
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);// Convertendo XFile para File, um provavel erro aqui
      });
    }
  }
  @override
  void dispose() {
    // Descartar os controladores de texto quando o widget é removido da árvore de widgets
    _width.dispose();
    _height.dispose();
    _length.dispose();
    _weight.dispose();
    super.dispose();
  }

  // Função chamada quando o botão 'Continuar' é pressionado
  void _onContinuePressed() async {
    // Se o formulário for válido, proceda com a operação desejada
    if (_formKey.currentState!.validate()) {
      print('All fields are valid. Proceeding to the next step...');

      // Cria um objeto Order com as informações inseridas pelo usuário
      Order order = Order(
        origin: '${widget.origin.latitude},${widget.origin.longitude}', // Converte a origem para uma string de coordenadas
        destination: '${widget.destination.latitude},${widget.destination.longitude}',// Converte o destino para uma string de coordenadas
        category: widget.categoryType.toUpperCase(), // Converte a categoria para maiúsculas
        width: int.parse(_width.text),
        height: int.parse(_height.text),
        length: int.parse(_length.text),
        weight: double.parse(_weight.text),
      );

      try {
        // Navega para a OrderCostScreen e passa o custo estimado como argumento
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderCostScreen(order: order),
          ),
        );

      } catch (e) {
        // Imprime qualquer erro que ocorra durante a chamada da função
        print('Error estimating order cost: $e');
      }
    }
  }

  // Método para obter o limite máximo para a medida e o tipo de transporte fornecidos
  double _getMaxLimit(String transportType, String measure) {
    Map<String, Map<String, double>> transportLimits = {
      'Small': {'width': 40, 'height': 40, 'length': 40, 'weight': 10},
      'Medium': {'width': 80, 'height': 80, 'length': 80, 'weight': 30},
      'Large': {'width': 150, 'height': 150, 'length': 150, 'weight': 90},
      'Default': {'width': 100, 'height': 100, 'length': 100, 'weight': 100},
    };
// Retorna o limite máximo para a medida e o tipo de transporte fornecidos
    return transportLimits[transportType]?[measure] ?? transportLimits['Default']![measure]!;
  }

  String? validateInput(String? value, String measure, String categoryTransport) {
    if (value == null || value.isEmpty) {
      return 'Please enter $measure.';
    }

    double? number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number for $measure.';
    }

    if (number <= 0) {
      return 'Please enter a number greater than 0 for $measure.';
    }

    double maxLimit = _getMaxLimit(categoryTransport, measure);

    if (number > maxLimit) {
      return 'The maximum allowed is $maxLimit to use $categoryTransport transport.';
    }

    return null;
  }
  @override
  Widget build(BuildContext context) {
    // Construção do layout da página de verificação de medidas
    return Scaffold(
      appBar: AppBar(
        title: Text('Check Measures'),
        backgroundColor: Colors.white, // Cor da AppBar
      ),
      // Formulário para validar os campos de texto
      body: Form(
        key: _formKey,
        // SingleChildScrollView para permitir rolagem quando o teclado aparecer
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          // Coluna para organizar os campos de texto e o botão
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Espaçamento antes do ícone de encomenda
              SizedBox(height: 20),
              // Ícone de encomenda centralizado
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.deepPurpleAccent,
                child: Icon(// Ícone com base no tipo de transporte
                  widget.categoryType == 'Small' ? Icons.motorcycle_outlined :
                  widget.categoryType == 'Medium' ? Icons.car_rental :
                  widget.categoryType == 'Large' ? Icons.cabin :
                  Icons.local_shipping_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20), // Espaço após o ícone de encomenda

              TextFormField(
                controller: _width,
                decoration: InputDecoration(
                  labelText: 'Width (cm)',
                  border: OutlineInputBorder(), // Adiciona bordas arredondadas
                  prefixIcon: Icon(Icons.straighten), // Adiciona um ícone
                ),
                keyboardType: TextInputType.number, // Mude para input de número
                validator: (value) => validateInput(value, 'width', widget.categoryType), // Adiciona validação personalizada
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _height,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.height),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => validateInput(value, 'height', widget.categoryType), // Adiciona validação personalizada
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _length,
                decoration: InputDecoration(
                  labelText: 'Length (cm)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.square_foot),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => validateInput(value, 'length', widget.categoryType), // Adiciona validação personalizada
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _weight,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => validateInput(value, 'weight', widget.categoryType), // Adiciona validação personalizada
              ),
              SizedBox(height: 20),

              if (_image != null) // Mostra a imagem selecionada
                Image.file(_image!, height: 150),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _onContinuePressed,
                child: Text('Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[350], // Altere a cor aqui se desejar
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
