//importacion de paquetes necesarios
import 'package:flutter/material.dart';
import 'package:control_de_gastos/db/db_helper.dart';
import 'package:control_de_gastos/models/gastos.dart';
import 'package:control_de_gastos/screens/new_gastos_screen.dart';
import 'package:control_de_gastos/widgets/gasto_card.dart';


// Pantalla principal de la aplicación *(HomeScreen {constructor})*
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


String formatDouble(double valor) {
  if (valor % 1 == 0) {
    return valor.toInt().toString();
  } else {
    return valor.toString();
  }
}


class _HomeScreenState extends State<HomeScreen> {
  final DBHelper dbHelper = DBHelper();
  List<Gasto> _gastos = [];
  double _gastosFijos = 0;
  double _ingresosMensuales = 0;

  final TextEditingController _fijosController = TextEditingController();
  final TextEditingController _ingresosController = TextEditingController();

  double get gastoTotal {
    return _gastos.fold(0.0, (double suma, Gasto gasto) {
      return suma + gasto.monto;
    });
  }

  // Método para inicializar la pantalla
  @override
  void initState() {
    super.initState();
    _cargarGastos();
    DBHelper.obtenerConfiguracion().then((valores) {
      setState(() {
      _ingresosController.text = formatDouble(valores['ingresos'] ?? 0.0);
      _fijosController.text = formatDouble(valores['gastosFijos'] ?? 0.0);
      
      _ingresosMensuales = valores['ingresos']!;
      _gastosFijos = valores['gastosFijos']!;
      });
    });
  }

  // Método para cargar los gastos desde la base de datos
  // y actualizar el estado de la pantalla
  Future<void> _cargarGastos() async {
    final gastos = await DBHelper.getGastos();
    setState(() {
      _gastos = gastos;
    });
  }

  // Método para borrar todos los gastos de la base de datos
  // Se muestra un diálogo de confirmación antes de proceder a borrar
  void _borrarTodosGastos() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar'),
            content: const Text('¿Seguro que deseas borrar todos los gastos?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí, borrar'),
              ),
            ],
          ),
    );


    if (confirmacion ?? false) {
      await DBHelper.deleteAllGastos();
      _cargarGastos();
    }
  }

  
  //interfaz de usuario de la pantalla principal
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Gastos')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Gastos fijos
            TextField(
              controller: _fijosController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                  labelText: 'Gastos Fijos',
                    prefixIcon: Icon(Icons.attach_money),
                  labelStyle: TextStyle(
                      fontSize: 22,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500
                  ),
              ),
              onChanged: (val) {
                setState(() {
                  _gastosFijos = double.tryParse(val) ?? 0;
                });
              },
            ),

            // Ingresos mensuales
            TextField(
              controller: _ingresosController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  fontSize: 18,
              ),
              decoration: const InputDecoration(
                labelText: 'Ingresos Mensuales',
                  prefixIcon: Icon(Icons.attach_money),
                labelStyle: TextStyle(
                  fontSize: 25,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w500

                )
              ),
              onChanged: (val) {
                setState(() {
                  _ingresosMensuales = double.tryParse(val) ?? 0;
                });
              },
            ),

            //Boton para guardar ingresos mensuales e gastos fijos
            const SizedBox(height: 10),
            ElevatedButton.icon(
              label: const Text('Guardar Ingresos y gastos',
              style: TextStyle(color: Colors.white70)
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green [300]),
              icon: const Icon(Icons.save),
              onPressed: () {
                final ingresos = double.tryParse(_ingresosController.text) ?? 0.0;
                final gastosFijos = double.tryParse(_fijosController.text) ?? 0.0;
                DBHelper.guardarConfiguracion(ingresos, gastosFijos);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Gastos e ingresos guardados exitosamente'),
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.green,
                  ),
                );
              },
            ),

            // Posible Ahorro
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
              'Ahorro y Gastos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container (
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber[400],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Ahorro: \$${(_ingresosMensuales - _gastosFijos - gastoTotal).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber[400],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    'Gasto total: \$${gastoTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),



            // Lista de gastos
            Expanded(
              child:
                  _gastos.isEmpty
                      ? const Center(child: Text('No hay gastos agregados.'))
                      : ListView.builder(
                        itemCount: _gastos.length,
                        itemBuilder: (context, index) {
                          return GastoCard(
                            gasto: _gastos[index],
                            onDeleted: () async {
                              await DBHelper.deleteGasto(_gastos[index].id!);
                              _cargarGastos();
                            },
                            onUpdate: (updateGasto) async {
                              await DBHelper.updateGasto (updateGasto);
                              setState(() {
                                int index = _gastos.indexWhere((g) => g.id == updateGasto.id);
                                if (index != -1) {
                                  _gastos[index] = updateGasto;
                                }
                              });
                            },
                          );
                        },
                      ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Gasto'),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NewGastosScreen(),
                        ),
                      );
                      _cargarGastos();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Borrar Todos',
                    style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: _borrarTodosGastos,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
