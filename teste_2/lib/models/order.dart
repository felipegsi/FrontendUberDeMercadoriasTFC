// Dentro de /lib/models/order.dart
import 'package:decimal/decimal.dart';

class Order {
  final String origin;
  final String destination;
  final String? description;
  final String? feedback;
  final String category; // Supondo que a categoria seja uma string
  final int width;
  final int height;
  final int length;
  final double weight;

  final Decimal? value; // Supondo que o valor seja um BigDecimal


  final String? status; // Adicionei um status para o pedido
  final DateTime? data; // Adicionei a data combinada com o time


  Order({
    required this.origin,
    required this.destination,
    this.description,
    this.feedback,
    required this.category,
    required this.width,
    required this.height,
    required this.length,
    required this.weight,
    this.value,
    this.status,
    this.data,
  });



  // Adiciona o método toJson
  Map<String, dynamic> toJson() {
    return {
      'origin': origin,
      'destination': destination,
      'description': description,
      'feedback': feedback,
      'category': category, // Converte o enum em String
      'width': width,
      'height': height,
      'length': length,
      'weight': weight,
      'value': value,
      'status': status,
      'data': data,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      origin: json['origin'],
      destination: json['destination'],
      description: json['description'],
      feedback: json['feedback'],
      category: json['category'],
      width: json['width'],
      height: json['height'],
      length: json['length'],
      weight: (json['weight'] as num).toDouble(), // Garante que seja um double
      value: Decimal.parse(json['value'].toString()), // Converte para Decimal
      status: json['status'],
      data: DateTime.parse(json['data']),
    );
  }
}
