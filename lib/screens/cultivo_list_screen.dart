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
    if (result == true && mounted) {
      _refreshCultivos();
    }
  }

  /// Muestra un modal para editar un cultivo.
  Future<void> _showEditDialog(Cultivo cultivo) async {
    final nombreController = TextEditingController(text: cultivo.nombre);
    final tipoController = TextEditingController(text: cultivo.tipo ?? '');
    DateTime? selectedDate = cultivo.fecha;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar Cultivo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tipoController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Fecha',
                        border: const OutlineInputBorder(),
                        hintText: selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                            : 'Seleccione una fecha',
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.green,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nombreController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('El nombre no puede estar vacío'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final updatedCultivo = Cultivo(
                      id: cultivo.id,
                      nombre: nombreController.text.trim(),
                      tipo: tipoController.text.trim().isEmpty ? null : tipoController.text.trim(),
                      fecha: selectedDate,
                    );

                    try {
                      final success = await _service.updateCultivo(updatedCultivo);
                      if (success) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cultivo actualizado correctamente'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                          _refreshCultivos();
                        }
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al actualizar el cultivo'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Muestra un diálogo de confirmación antes de eliminar un cultivo.
  Future<void> _confirmDelete(int id, String nombre) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar el cultivo "$nombre"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
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
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cultivo eliminado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            _refreshCultivos();
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al eliminar el cultivo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
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
                    (Set<MaterialState> states) {
                      return Colors.green[100];
                    },
                  ),
                  dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.green[50];
                      }
                      return null;
                    },
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
                  rows: cultivos.map((cultivo) {
                    return DataRow(
                      cells: [
                        DataCell(Text(cultivo.nombre)),
                        DataCell(Text(cultivo.tipo ?? 'Sin Tipo')),
                        DataCell(
                          Text(
                            cultivo.fecha != null
                                ? DateFormat('dd/MM/yyyy').format(cultivo.fecha!)
                                : 'Sin Fecha',
                          ),
                        ),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => _showEditDialog(cultivo),
                              tooltip: 'Editar',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(cultivo.id, cultivo.nombre),
                              tooltip: 'Eliminar',
                            ),
                          ],
                        )),
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}