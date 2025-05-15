//interaccion con la base de datos SQLite
//Clase Gasto, que representa un gasto individual
class Gasto {
  final int? id;
  final String descripcion;
  final double monto;
  final String categoria;
  final String fecha;

  //Constructor de la clase Gasto
  Gasto({
    this.id,
    required this.descripcion,
    required this.monto,
    required this.categoria,
    required this.fecha,
  });

  //Convierte un mapa SQLite a un objeto Gasto
  factory Gasto.fromMap(Map<String, dynamic> json) => Gasto(
    id: json['id'],
    descripcion: json['descripcion'],
    monto: json['monto'],
    categoria: json['categoria'],
    fecha:
        json['fecha']
                is String //Verifica si la fecha es un String o DateTime
            ? json['fecha']
            : (json['fecha'] as DateTime).toIso8601String(),
  );

  // Convertir objeto Gasto a mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'monto': monto,
      'categoria': categoria,
      'fecha': fecha,
    };
  }
}
