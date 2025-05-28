import 'package:flutter/material.dart';
import '../models/cultivo.dart';
import '../services/cultivo_service.dart';

/// Pantalla para crear un nuevo cultivo.
class CrearCultivoScreen extends StatefulWidget {
  final Cultivo? cultivo; // Si es null, es creación; si no, edición

  const CrearCultivoScreen({super.key, this.cultivo});

  @override
  _CrearCultivoScreenState createState() => _CrearCultivoScreenState();
}

class _CrearCultivoScreenState extends State<CrearCultivoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _fechaController = TextEditingController();
  final CultivoService _cultivoService = CultivoService();
  bool _isSaving = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.cultivo != null) {
      _nombreController.text = widget.cultivo!.nombre;
      _tipoController.text = widget.cultivo!.tipo ?? '';
      if (widget.cultivo!.fecha != null) {
        _selectedDate = widget.cultivo!.fecha;
        _fechaController.text =
            "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}";
      }
    }
  }

  /// Guarda el cultivo en el servicio y maneja la respuesta.
  Future<void> _guardarCultivo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      try {
        final cultivo = Cultivo(
          id: widget.cultivo?.id ?? 0,
          nombre: _nombreController.text.trim(),
          tipo:
              _tipoController.text.trim().isEmpty
                  ? null
                  : _tipoController.text.trim(),
          fecha: _selectedDate,
        );

        bool exito;
        if (widget.cultivo == null) {
          exito = await _cultivoService.addCultivo(cultivo);
        } else {
          exito = await _cultivoService.updateCultivo(cultivo);
        }

        setState(() => _isSaving = false);

        if (exito) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.cultivo == null
                      ? 'Cultivo creado correctamente'
                      : 'Cultivo actualizado correctamente',
                ),
              ),
            );
            Navigator.pop(context, true);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.cultivo == null
                      ? 'Error al crear el cultivo'
                      : 'Error al actualizar el cultivo',
                ),
              ),
            );
          }
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
        }
      }
    }
  }

  /// Muestra un selector de fecha y actualiza el controlador.
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _tipoController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar Cultivo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingrese un nombre válido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(labelText: 'Tipo (opcional)'),
              ),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(labelText: 'Fecha'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Por favor, seleccione una fecha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _isSaving ? null : _guardarCultivo,
                    child: const Text('Guardar'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
