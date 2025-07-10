import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cultivo.dart';
import '../services/cultivo_service.dart';

class CrearCultivoScreen extends StatefulWidget {
  final Cultivo? cultivo;

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
        _fechaController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
      }
    }
  }

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

        if (mounted) {
          setState(() => _isSaving = false);
          if (exito) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  widget.cultivo == null
                      ? 'Cultivo creado correctamente'
                      : 'Cultivo actualizado correctamente',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error al guardar el cultivo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
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
      appBar: AppBar(
        title: Text(
          widget.cultivo == null ? 'Agregar Cultivo' : 'Editar Cultivo',
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, ingrese un nombre válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tipoController,
                decoration: const InputDecoration(
                  labelText: 'Tipo (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category, color: Colors.green),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.green),
                ),
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
                  ? const CircularProgressIndicator(color: Colors.green)
                  : ElevatedButton(
                    onPressed: _isSaving ? null : _guardarCultivo,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
