class ResenaModelo {
  final String id;
  final String libroId;
  final String usuarioId;
  final String nombreUsuario;
  final String? fotoUsuario;
  final String comentario;
  final double calificacion;
  final DateTime fechaCreacion;

  ResenaModelo({
    required this.id,
    required this.libroId,
    required this.usuarioId,
    required this.nombreUsuario,
    this.fotoUsuario,
    required this.comentario,
    required this.calificacion,
    required this.fechaCreacion,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'libroId': libroId,
      'usuarioId': usuarioId,
      'nombreUsuario': nombreUsuario,
      'fotoUsuario': fotoUsuario,
      'comentario': comentario,
      'calificacion': calificacion,
      'fechaCreacion': fechaCreacion.toIso8601String(),
    };
  }

  factory ResenaModelo.fromMap(Map<String, dynamic> map) {
    return ResenaModelo(
      id: map['id'] as String,
      libroId: map['libroId'] as String,
      usuarioId: map['usuarioId'] as String,
      nombreUsuario: map['nombreUsuario'] as String,
      fotoUsuario: map['fotoUsuario'] as String?,
      comentario: map['comentario'] as String,
      calificacion: (map['calificacion'] as num).toDouble(),
      fechaCreacion: DateTime.parse(map['fechaCreacion'] as String),
    );
  }
}
