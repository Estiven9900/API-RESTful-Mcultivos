import 'dart:convert';
import 'package:http/http.dart' as http;

// Cambia la URL base según tu configuración
const String baseUrl = 'http://127.0.0.1:8000/api';

class AuthService {
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Login - Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Register - Status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Register failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  // Ejemplo de función para obtener cultivos protegidos
  Future<void> getCultivos(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/cultivos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Aquí va el token
      },
    );

    if (response.statusCode == 200) {
      print('Cultivos: ${response.body}');
    } else {
      print('Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String?> loginAndGetToken(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token']; // Ajusta según la clave que retorne tu backend
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}