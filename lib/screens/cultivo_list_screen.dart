import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cultivo_service.dart';
import '../models/cultivo.dart';
import 'crear_cultivo_screen.dart';
import 'login_screen.dart';

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
  Future<void> _navigateToCreateScreen({Cultivo? cultivo}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CrearCultivoScreen(cultivo: cultivo),
      ),
    );
    if (result == true && mounted) {
      _refreshCultivos();
    }
  }

  /// Muestra un diálogo de confirmación antes de eliminar un cultivo.
  Future<void> _confirmDelete(int id, String nombre) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de que deseas eliminar el cultivo "$nombre"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final success = await _service.deleteCultivo(id);
        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cultivo eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          _refreshCultivos();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al eliminar el cultivo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cultivos'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            color: Colors.red,
            iconSize: 28,
            onPressed: () async {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            splashRadius: 24,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ],
      ),
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
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) => Colors.green[100],
                  ),
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
                    DataColumn(
                      label: Text(
                        'Acciones',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows:
                      cultivos.map((cultivo) {
                        return DataRow(
                          cells: [
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
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    tooltip: 'Editar',
                                    onPressed:
                                        () => _navigateToCreateScreen(
                                          cultivo: cultivo,
                                        ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'Eliminar',
                                    onPressed:
                                        () => _confirmDelete(
                                          cultivo.id,
                                          cultivo.nombre,
                                        ),
                                  ),
                                ],
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
        onPressed: () => _navigateToCreateScreen(),
        tooltip: 'Agregar Cultivo',
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
