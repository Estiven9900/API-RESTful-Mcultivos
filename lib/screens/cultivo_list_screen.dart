import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cultivo_service.dart';
import '../models/cultivo.dart';
import 'crear_cultivo_screen.dart';

/// Pantalla que muestra una lista de cultivos.
class CultivoListScreen extends StatefulWidget {
  const CultivoListScreen({super.key});

  @override
  _CultivoListScreenState createState() => _CultivoListScreenState();
}

class _CultivoListScreenState extends State<CultivoListScreen> {
  final CultivoService _service = CultivoService();
  late Future<List<Cultivo>> _futureCultivos;

  @override
  void initState() {
    super.initState();
    _refreshCultivos();
  }

  /// Carga la lista de cultivos desde el servicio.
  void _refreshCultivos() {
    setState(() {
      _futureCultivos = _service.getCultivos();
    });
  }

  /// Navega a la pantalla de creación de cultivo y recarga la lista al regresar.
  Future<void> _navigateToCreateScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CrearCultivoScreen()),
    );
    if (mounted && result == true) {
      _refreshCultivos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cultivos')),
      body: FutureBuilder<List<Cultivo>>(
        future: _futureCultivos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error al cargar cultivos: ${snapshot.error}'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _refreshCultivos,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final cultivos = snapshot.data!;
            return ListView.builder(
              itemCount: cultivos.length,
              itemBuilder: (context, index) {
                final cultivo = cultivos[index];
                return ListTile(
                  title: Text(cultivo.nombre),
                  subtitle: Text(
                    cultivo.tipo != null && cultivo.fecha != null
                        ? 'Tipo: ${cultivo.tipo} | Fecha: ${DateFormat('dd/MM/yyyy').format(cultivo.fecha!)}'
                        : cultivo.tipo ?? 'Sin Tipo',
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No hay cultivos registrados.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateScreen(context),
        tooltip: 'Agregar Cultivo',
        child: const Icon(Icons.add),
      ),
    );
  }
}