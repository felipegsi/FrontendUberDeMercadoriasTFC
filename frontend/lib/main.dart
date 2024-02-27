import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class Cliente {
  int? id;
  String nome;
  String email;

  Cliente({this.id, required this.nome, required this.email});

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
    };
  }
}

class ClienteService {
  static const String _baseUrl = 'http://10.0.2.2:8080/clientes';

  Future<List<Cliente>> getClientes() async {
    final response = await http.get(Uri.parse(_baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> clientesJson = json.decode(response.body);
      return clientesJson.map((json) => Cliente.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clientes');
    }
  }

  Future<Cliente> addCliente(Cliente cliente) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente.toJson()),
    );
    if (response.statusCode == 201) {
      return Cliente.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add cliente');
    }
  }

  Future<void> deleteCliente(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete cliente');
    }
  }

  Future<void> updateCliente(Cliente cliente) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${cliente.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(cliente.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update cliente');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Cliente',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ClientePage(),
    );
  }
}

class ClientePage extends StatefulWidget {
  @override
  _ClientePageState createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  final ClienteService _clienteService = ClienteService();
  List<Cliente> _clientes = [];
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClientes();
  }

  Future<void> _loadClientes() async {
    final clientes = await _clienteService.getClientes();
    setState(() {
      _clientes = clientes;
    });
  }

  Future<void> _addCliente() async {
    final cliente = Cliente(nome: _nomeController.text, email: _emailController.text);
    try {
      final addedCliente = await _clienteService.addCliente(cliente);
      setState(() {
        _clientes.add(addedCliente);
      });
    } catch (e) {
      print(e); // Para fins de debug.
    } finally {
      // Limpa os campos de entrada independentemente do resultado da operação.
      _nomeController.clear();
      _emailController.clear();
    }
  }





  Future<void> _deleteCliente(int id) async {
    try {
      await _clienteService.deleteCliente(id);
      setState(() {
        _clientes.removeWhere((cliente) => cliente.id == id);
      });
    } catch (e) {
      print(e); // Apenas para fins de debug. Considere implementar tratamento de erro adequado.
    }
  }

  Future<void> _updateCliente(Cliente cliente) async {
    try {
      cliente.nome = _nomeController.text;
      cliente.email = _emailController.text;
      await _clienteService.updateCliente(cliente);
      int index = _clientes.indexWhere((c) => c.id == cliente.id);
      if (index != -1) {
        setState(() {
          _clientes[index] = cliente;
        });
      }
      _nomeController.clear();
      _emailController.clear();
    } catch (e) {
      print(e); // Apenas para fins de debug. Considere implementar tratamento de erro adequado.
    }
  }

  @override
  Widget build    (context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Cliente'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final cliente = _clientes[index];
                return ListTile(
                  title: Text(cliente.nome),
                  subtitle: Text(cliente.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _nomeController.text = cliente.nome;
                          _emailController.text = cliente.email;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Atualizar Cliente'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  TextField(
                                    controller: _nomeController,
                                    decoration: InputDecoration(labelText: 'Nome'),
                                  ),
                                  TextField(
                                    controller: _emailController,
                                    decoration: InputDecoration(labelText: 'Email'),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancelar'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: Text('Atualizar'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _updateCliente(cliente);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteCliente(cliente.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addCliente,
            child: Text('Adicionar Cliente'),
          ),
        ],
      ),
    );
  }
}
