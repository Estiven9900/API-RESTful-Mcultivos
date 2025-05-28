import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cultivo_service.dart';
import '../models/cultivo.dart';
import 'crear_cultivo_screen.dart';

/// Pantalla que muestra una lista de cultivos en una tabla.
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
    } else {
      _refreshCultivos(); // Siempre refresca al volver
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
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Card(
                elevation: 4,
                margin: const EdgeInsets.all(16),
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    return Colors.green[100];
                  }),
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>((
                    Set<MaterialState> states,
                  ) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.green[50];
                    }
                    return null;
                  }),
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Nombre',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Tipo',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Fecha',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows:
                      cultivos.map((cultivo) {
                        return DataRow(
                          cells: [
                            DataCell(Text(cultivo.id.toString())),
                            DataCell(Text(cultivo.nombre)),
                            DataCell(Text(cultivo.tipo ?? 'Sin Tipo')),
                            DataCell(
                              Text(
                                cultivo.fecha != null
                                    ? DateFormat(
                                      'dd/MM/yyyy',
                                    ).format(cultivo.fecha!)
                                    : 'Sin Fecha',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
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
