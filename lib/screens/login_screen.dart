import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'cultivo_list_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos de texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Bandera para alternar la visibilidad de la contraseña
  bool _obscurePassword = true;

  // Bandera para el indicador de carga
  bool _isLoading = false;

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Manejar el inicio de sesión con el backend
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final authService = AuthService();
        final success = await authService.login(
          _emailController.text,
          _passwordController.text,
        );

        if (success) {
          // Navegar a la pantalla de lista de cultivos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CultivoListScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Correo o contraseña incorrectos')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Validación del correo electrónico
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu correo electrónico';
    }
    // Patrón regex básico para validar el formato del correo
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor, ingresa un correo electrónico válido';
    }
    return null;
  }

  // Validación de la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contraseña';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Título de la aplicación
                  const Text(
                    'Gestión de Cultivos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48.0),

                  // Campo de correo electrónico
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.green),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16.0),

                  // Campo de contraseña
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock, color: Colors.green),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                  ),
                  const SizedBox(height: 24.0),

                  // Botón de inicio de sesión
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 18.0),
                          ),
                  ),
                  const SizedBox(height: 16.0),

                  // Enlace para "¿Olvidaste tu contraseña?"
                  TextButton(
                    onPressed: () {
                      // Placeholder para recuperación de contraseña
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                  const SizedBox(height: 8.0),

                  // Enlace para "Registrarse"
                  TextButton(
                    onPressed: () {
                      // Placeholder para registro
                    },
                    child: const Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}