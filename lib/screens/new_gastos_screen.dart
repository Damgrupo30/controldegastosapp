//importacion de paquetes necesarios
import 'package:flutter/material.dart';
import 'package:control_de_gastos/db/db_helper.dart';
import 'package:control_de_gastos/models/gastos.dart';
import 'package:intl/intl.dart';

// Pantalla para agregar un nuevo gasto
// Esta pantalla permite al usuario ingresar la descripción, monto, categoría y fecha del gasto
class NewGastosScreen extends StatefulWidget {
  const NewGastosScreen({super.key});

  @override
  State<NewGastosScreen> createState() => _NewGastosScreenState();
}

// Clase interna para manejar el estado del widget NewGastosScreen
// Esta clase es responsable de manejar la lógica de la pantalla de agregar gasto
class _NewGastosScreenState extends State<NewGastosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descripcionController = TextEditingController();
  final _montoController = TextEditingController();
  String? _categoriaSeleccionada;
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

  //Funcion para guardar el gasto en la base de datos
  // Se valida el formulario y se inserta el gasto en la base de datos
  void _guardarGasto() async {
    if (_formKey.currentState!.validate() && _categoriaSeleccionada != null) {
      final nuevoGasto = Gasto(
        descripcion: _descripcionController.text.trim(),
        monto: double.parse(_montoController.text.trim()),
        categoria: _categoriaSeleccionada!,
        fecha: DateFormat('yyyy-MM-dd').format(_fechaSeleccionada),
      );

      await DBHelper.insertGasto(nuevoGasto);
      if (!mounted) return;
      if (context.mounted) {
        Navigator.pop(context, true); // Para actualizar al regresar
      }
    }
  }

  // Función para seleccionar la fecha del gasto
  // Se utiliza el paquete intl para formatear la fecha seleccionada
  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  // Método para limpiar los controladores de texto al cerrar la pantalla
  @override
  void dispose() {
    _descripcionController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  //interfaz de usuario de la pantalla
  // Se utiliza un formulario para ingresar los datos del gasto
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
                  child: const Text('Guardar Gasto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
