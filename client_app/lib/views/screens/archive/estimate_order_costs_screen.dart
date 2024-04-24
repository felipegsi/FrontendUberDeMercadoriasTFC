import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../enums/category.dart';
import '../../../services/network_service.dart';
import '../../../models/order.dart';
import 'package:decimal/decimal.dart';

class EstimateOrderCostScreen extends StatefulWidget {
  @override
  _EstimateOrderCostScreenState createState() =>
      _EstimateOrderCostScreenState();
}

class _EstimateOrderCostScreenState extends State<EstimateOrderCostScreen> {
  final _formKey = GlobalKey<FormState>();
  final originController = TextEditingController();
  final destinationController = TextEditingController();

  // Assumindo que você tenha um enum para categorias
  final categoryController = TextEditingController();
  final widthController = TextEditingController();
  final heightController = TextEditingController();
  final lengthController = TextEditingController();
  final weightController = TextEditingController();
  bool _isSubmitting = false;
  String? _estimatedCost;

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    categoryController.dispose();
    widthController.dispose();
    heightController.dispose();
    lengthController.dispose();
    weightController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        // Convert the string from the categoryController to the enum type Category.

        Order order = Order(
          origin: originController.text,
          destination: destinationController.text,
          description: 'Description',
          // Optional, depends on your data model
          feedback: 'Feedback',
          // Optional, depends on your data model
          category: categoryController.text,
          // Converted from the input string
          width: int.parse(widthController.text),
          height: int.parse(heightController.text),
          length: int.parse(lengthController.text),
          weight: double.parse(weightController.text),
        );
        print(order.toJson());
        // The rest of your code...

        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? token = prefs.getString('token');

        if (token != null) {
          try {
          //  Decimal cost = await NetworkService().estimateOrderCost(order);
            setState(() {
            //  _estimatedCost = cost.toString();
              _isSubmitting = false;
            });
          } catch (e) {
            setState(() {
              _estimatedCost = 'Erro ao estimar o custo: ${e.toString()}';
              _isSubmitting = false;
            });
          }
        } else {
          setState(() {
            _estimatedCost = 'Token não está disponível.';
            _isSubmitting = false;
          });
        }
      } catch (e) {
        // Handle the error, e.g., show a Snackbar with the error message
        setState(() {
          _isSubmitting = false;
          _estimatedCost = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estimar Custo da Encomenda')),
      body: _isSubmitting
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: originController,
                      decoration:
                          InputDecoration(labelText: 'Origem (lat,lng)'),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Origem é obrigatória'
                          : null,
                    ),
                    TextFormField(
                      controller: destinationController,
                      decoration:
                          InputDecoration(labelText: 'Destino (lat,lng)'),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Destino é obrigatório'
                          : null,
                    ),
                    // Outros campos aqui...

                    TextFormField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: 'Categoria'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Categoria é obrigatória';
                        } else if (getCategoryFromString(value) == null) {
                          return 'Categoria inválida';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: widthController,
                      decoration: InputDecoration(labelText: 'Largura'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Largura é obrigatória';
                        } else if (int.tryParse(value) == null) {
                          return 'Largura deve ser um número';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: heightController,
                      decoration: InputDecoration(labelText: 'Altura'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Altura é obrigatória';
                        } else if (int.tryParse(value) == null) {
                          return 'Altura deve ser um número';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: lengthController,
                      decoration: InputDecoration(labelText: 'Comprimento'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Comprimento é obrigatório';
                        } else if (int.tryParse(value) == null) {
                          return 'Comprimento deve ser um número';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: weightController,
                      decoration: InputDecoration(labelText: 'Peso'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Peso é obrigatório';
                        } else if (double.tryParse(value) == null) {
                          return 'Peso deve ser um número';
                        }
                        return null;
                      },
                    ),

                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('Submeter'),
                    ),
                    if (_estimatedCost != null) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Custo estimado: $_estimatedCost'),
                      )
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
