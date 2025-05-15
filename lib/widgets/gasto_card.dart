// Aqui importamos dependencias necesarias
// y el modelo de Gastos
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:control_de_gastos/models/gastos.dart';
import 'package:control_de_gastos/screens/edit_gasto_screens.dart';
import 'package:intl/intl.dart';

//Widget para mostrar cada gasto en la lista
//Este widget es un StatefulWidget porque tiene un estado interno (_expandido)
//Recibe un objeto Gasto y una función onDeleted como parámetros
// La función onDeleted se llama cuando se elimina un gasto
class GastoCard extends StatefulWidget {
  final Gasto gasto;
  final VoidCallback onDeleted;
  final Function(Gasto) onUpdate;

  const GastoCard({
    super.key,
    required this.gasto,
    required this.onDeleted,
    required this.onUpdate,
  });

  @override
  State<GastoCard> createState() => _GastoCardState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('onUpdate', onUpdate));
  }
}

// Función para obtener el color según la categoría del gasto
Color obtenerColorPorCategoria(String categoria) {
  switch (categoria) {
    case 'Gasto fijo':
      return Colors.green.shade100;
    case 'Ingreso mensual':
      return Colors.green.shade200;
    case 'Posible ahorro':
      return Colors.blue.shade100;
    default:
      return Colors.grey.shade200;
  }
}

// Función para obtener el icono según la categoría del gasto
Widget iconoPorCategoria(String categoria) {
  switch (categoria.trim().toLowerCase()) {
    case 'salud':
      return Icon(Icons.health_and_safety, color: Colors.red, size: 35);
    case 'alimentacion':
      return Icon(Icons.fastfood, color: Colors.orange, size: 35);
    case 'ropa':
      return Icon(Icons.checkroom_outlined, color: Colors.indigo, size: 35);
    case 'transporte':
      return Icon(Icons.commute_rounded, color: Colors.purple, size: 35);
    case 'estudio':
      return Icon(Icons.school_rounded, color: Colors.blue, size: 35);
    case 'cafe':
      return Icon(Icons.free_breakfast, color: Colors.brown, size: 35);
    case 'otros':
      return Icon(Icons.shopping_cart, color: Colors.pink, size: 35);
    default:
      return Icon(Icons.help_outline, color: Colors.grey, size: 35);
  }
}

// Clase interna para manejar el estado del widget GastoCard
//_expandido es un booleano que indica si la tarjeta está expandida o no
class _GastoCardState extends State<GastoCard> {
  bool _expandido = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandido = !_expandido;
        });
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.gasto.descripcion,
                style: const TextStyle(fontSize: 16),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      iconoPorCategoria(widget.gasto.categoria),
                      const SizedBox(width: 8),
                      Text(
                        '\$${widget.gasto.monto.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final updateGasto = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditarGastoScreen(gasto: widget.gasto),
                            ),
                          );
                          if (updateGasto != null) {
                            widget.onUpdate(updateGasto);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmacion = await showDialog<bool>(
                            context: context,
                            builder: (context) =>
                                AlertDialog(
                                  title: const Text('Eliminar gasto'),
                                  content: const Text(
                                    '¿Estás seguro de que deseas eliminar este gasto?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmacion == true) {
                            widget.onDeleted();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              if (_expandido) const SizedBox(height: 8),
              if (_expandido)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categoría: ${widget.gasto.categoria}'),
                    Text(
                      'Fecha: ${DateFormat('dd/MM/yyyy').format(
                          DateTime.parse(widget.gasto.fecha))}',
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  }




