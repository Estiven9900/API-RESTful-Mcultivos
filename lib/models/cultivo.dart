/// Representa un cultivo con sus propiedades básicas.
class Cultivo {
  /// Identificador único del cultivo.
  final int id;

  /// Nombre del cultivo.
  final String nombre;

  /// Tipo del cultivo (opcional).
  final String? tipo;

  /// Fecha asociada al cultivo (opcional).
  final DateTime? fecha;

  /// Constructor de la clase [Cultivo].
  Cultivo({
    required this.id,
    required this.nombre,
    this.tipo,
    this.fecha,
  });

  /// Crea un [Cultivo] a partir de un mapa JSON.
  ///
  /// Lanza una excepción si los campos requeridos (`id` o `nombre`) no son válidos.
  factory Cultivo.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! int) {
      throw FormatException('El campo "id" debe ser un entero.');
    }
    if (json['nombre'] is! String || json['nombre'].isEmpty) {
      throw FormatException('El campo "nombre" debe ser una cadena no vacía.');
    }

    return Cultivo(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'] as String?,
      fecha: json['fecha'] != null
          ? _parseDateTime(json['fecha'])
          : null,
    );
  }

  /// Convierte el objeto [Cultivo] a un mapa JSON.
  ///
  /// Incluye todos los campos, con valores nulos para los campos opcionales.
  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'tipo': tipo,
        'fecha': fecha?.toIso8601String(),
      };

  /// Parsea una cadena de fecha a [DateTime], manejando errores.
  static DateTime? _parseDateTime(dynamic fecha) {
    try {
      return DateTime.parse(fecha as String);
    } catch (e) {
      throw FormatException('Formato de fecha inválido: $fecha');
    }
  }
}