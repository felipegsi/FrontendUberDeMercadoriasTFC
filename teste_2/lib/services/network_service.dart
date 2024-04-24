import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../models/client.dart';
import '../models/order.dart';
import '../models/location.dart';
import 'package:decimal/decimal.dart';

import '../views/screens/auth/login_screen.dart';

class NetworkService {
  // Cria uma instância do FlutterSecureStorage para armazenar e recuperar o token de forma segura
  final storage = new FlutterSecureStorage();

  // URL base para todas as requisições
  final String baseUrl = 'http://10.0.2.2:8080/client';

  // Função para verificar se o token é válido
  Future<bool> isValidToken() async {
    // Recupera o token do armazenamento seguro
    String? token = await storage.read(key: 'token');
    // Se o token for nulo, retorna false
    if (token == null) {
      return false;
    }

    // Cria a URL para a rota de verificação de validade do token
    final url = Uri.parse('$baseUrl/isValidToken');
    // Envia uma requisição GET para a URL com o token no cabeçalho de autorização
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    // Se o código de status da resposta for 200, retorna true, caso contrário, retorna false
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // Função para registrar um novo cliente
  Future<bool> registerClient(Map<String, dynamic> clientData) async {
    // Cria a URL para a rota de registro
    final url = Uri.parse('$baseUrl/register');
    // Envia uma requisição POST para a URL com os dados do cliente no corpo da requisição
    final response = await http.post(url,
        body: json.encode(clientData),
        headers: {'Content-Type': 'application/json'});
    // Se o código de status da resposta for 200, imprime o cliente e retorna true
    if (response.statusCode == 200) {
      print(Client.fromJson(json.decode(response.body)));
      return true;
    } else {
      // Se o código de status da resposta não for 200, imprime o corpo da resposta e retorna false
      print('Erro ao registrar cliente: ${response.body}');
      return false;
    }
  }

  // Função para fazer login
  Future<String?> login(String email, String password) async {
    // Cria a URL para a rota de login
    final url = Uri.parse('$baseUrl/login');
    // Envia uma requisição POST para a URL com o e-mail e a senha no corpo da requisição
    final response = await http.post(url,
        body: json.encode({'email': email, 'password': password}),
        headers: {'Content-Type': 'application/json'});
    // Se o código de status da resposta for 200, salva o token no armazenamento seguro e retorna o token
    if (response.statusCode == 200) {
      await storage.write(key: 'token', value: response.body);
      print('Token: ${response.body}');
      return response.body; // Assume this is the token
    } else {
      // Se o código de status da resposta não for 200, imprime o corpo da resposta e retorna null
      print('Erro ao fazer login: ${response.body}');
      return null;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }

  Future<Client?> viewProfile(BuildContext context) async {
    // Recupera o token do FlutterSecureStorage
    String? token = await storage.read(key: 'token');
    if (token == null) {
      print('No token found');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      return null;
    }

    final url = Uri.parse('$baseUrl/viewProfile');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // Adicione 'Bearer ' antes do token
    });
    if (response.statusCode == 200) {
      return Client.fromJson(json.decode(response.body));
    }else {
      print('Invalid token');
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      return null;
    }
  }

  Future<List<Order>> getOrderHistory() async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('$baseUrl/orderHistory');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Iterable json = jsonDecode(response.body);
      return json.map((orderJson) => Order.fromJson(orderJson)).toList();
    } else {
      // Handle different status codes and errors here
      throw Exception('Failed to load order history: ${response.body}');
    }
  }



  Future<List<Decimal>> estimateAllCategoryOrderCost(Location location) async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    final url = Uri.parse('$baseUrl/estimateAllCategoryOrderCost');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(location.toJson()),
    );

    if (response.statusCode == 200) {
      List<dynamic> responseBody = jsonDecode(response.body);
      return responseBody.map((cost) => Decimal.parse(cost.toString())).toList();
    } else {
      throw Exception('Failed to estimate order cost: ${response.body}');
    }
  }

  Future<Decimal> estimateOrderCost(Order order) async {
    // Recupera o token do armazenamento seguro
    String? token = await storage.read(key: 'token');
    if (token == null) {
      throw Exception('No token found');
    }

    // Cria a URL para a rota de estimativa de custo do pedido
    final url = Uri.parse('$baseUrl/estimateOrderCost');

    // Converte o objeto Order para um mapa e depois para uma string JSON
    String orderJson = jsonEncode(order.toJson());

    // Envia uma requisição POST para a URL com o objeto Order no corpo da requisição e o token no cabeçalho de autorização
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: orderJson,
    );

    // Se o código de status da resposta for 200, converte o corpo da resposta para Decimal e retorna
    if (response.statusCode == 200) {
      return Decimal.parse(response.body);
    } else {
      // Se o código de status da resposta não for 200, lança uma exceção com a mensagem de erro
      throw Exception('Failed to estimate order cost: ${response.body}');
    }
  }

//deleta uma conta
// Na classe NetworkService
  Future<bool> deleteAccount(BuildContext context) async {
    String? token = await storage.read(key: 'token');
    if (token == null) {
      print('No token found');
      return false;
    }

    final url = Uri.parse('$baseUrl/deleteClient');
    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
      return true;
    } else {
      print('Erro ao deletar conta: ${response.body}');
      return false;
    }
  }




}


