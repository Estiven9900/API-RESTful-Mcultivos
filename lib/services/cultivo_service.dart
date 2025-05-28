import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cultivo.dart';

class CultivoService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/cultivos';

  // Listar todos los cultivos
  Future<List<Cultivo>> getCultivos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((json) => Cultivo.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los cultivos');
    }
  }

  // Agregar cultivo
  Future<bool> addCultivo(Cultivo cultivo) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cultivo.toJson()),
    );

    return response.statusCode == 201;
  }

  // Eliminar cultivo
  Future<bool> deleteCultivo(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    return response.statusCode == 200;
  }

  // Editar cultivo
  Future<bool> updateCultivo(Cultivo cultivo) async {
    final response = await http.put(
      Uri.parse('$baseUrl/${cultivo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cultivo.toJson()),
    );
    return response.statusCode == 200;
  }
}
