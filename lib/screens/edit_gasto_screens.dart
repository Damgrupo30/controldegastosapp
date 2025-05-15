import 'package:flutter/material.dart';
import 'package:control_de_gastos/models/gastos.dart';
import 'package:intl/intl.dart'; //

class EditarGastoScreen extends StatefulWidget {
  final Gasto gasto;

  const EditarGastoScreen({super.key, required this.gasto});

  @override
  _EditarGastoScreenState createState() => _EditarGastoScreenState();
}

class _EditarGastoScreenState extends State<EditarGastoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  String? _categoriaSeleccionada ;
  DateTime _fechaSeleccionada = DateTime.now();

  // Lista de categorías predefinidas para los gastos
  final List<String> _categorias = [
    'Salud',
    'Alimentacion',
    'Ropa',
    'Transporte',
    'Estudio',
    'Cafe',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    _descripcionController.text = widget.gasto.descripcion;
    _montoController.text = widget.gasto.monto.toString();
    _categoriaSeleccionada = widget.gasto.categoria;
    _fechaSeleccionada = DateTime.parse(widget.gasto.fecha);
  }

  void _seleccionarFecha() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _fechaSeleccionada = pickedDate;
      });
    }
  }

  void _guardarGasto() {
    if (_descripcionController.text.isNotEmpty && _montoController.text.isNotEmpty) {
      final updatedGasto = Gasto(
        id: widget.gasto.id,
        descripcion: _descripcionController.text,
        monto: double.tryParse(_montoController.text) ?? 0,
        categoria: _categoriaSeleccionada!,
        fecha: _fechaSeleccionada.toIso8601String(),
      );

      Navigator.pop(context, updatedGasto);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Gastos')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                validator:
                    (value) =>
                value == null || value.isEmpty
                    ? 'Ingrese una descripción'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese un monto';
                  if (double.tryParse(value) == null) {
                    return 'Ingrese un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoría'),
                value: _categoriaSeleccionada,
                items:
                _categorias
                    .map(
                      (categoria) => DropdownMenuItem(
                    value: categoria,
                    child: Text(categoria),
                  ),
                )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value;
                  });
                },
                validator:
                    (value) =>
                value == null ? 'Seleccione una categoría' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(_fechaSeleccionada)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _seleccionarFecha,
                    child: const Text('Seleccionar fecha'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarGasto,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black
                ),
                child: const Text('Actualizar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
