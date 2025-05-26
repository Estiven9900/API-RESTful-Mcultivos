import 'package:flutter/material.dart';
import 'screens/cultivo_list_screen.dart';

void main() {
  runApp(MiAppCultivos());
}

class MiAppCultivos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestión de Cultivos',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true, // si usas Material 3
      ),
      home: CultivoListScreen(), // pantalla principal
    );
  }
}