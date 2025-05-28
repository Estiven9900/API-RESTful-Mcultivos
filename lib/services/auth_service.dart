import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  // Iniciar sesión
  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email, // Asegúrate que tu backend espera "email"
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Puedes guardar el token si lo necesitas:
      // final data = jsonDecode(response.body);
      // String token = data['token'];
      return true;
    } else {
      return false;
    }
  }

  // Registrar usuario (opcional)
  Future<bool> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response.statusCode == 201;
  }
}
