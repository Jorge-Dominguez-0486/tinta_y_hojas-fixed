import 'package:cloud_firestore/cloud_firestore.dart';

class ResenaModelo {
  final String id;
  final String usuarioId;
  final String usuarioNombre;
  final String comentario;
  final double calificacion;
  final DateTime createdAt;

  ResenaModelo({
    required this.id,
    this.usuarioId = '',
    this.usuarioNombre = '',
    this.comentario = '',
    this.calificacion = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'comentario': comentario,
      'calificacion': calificacion,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ResenaModelo.fromMap(Map<String, dynamic> map) {
    return ResenaModelo(
      id: (map['id'] ?? '').toString(),
      usuarioId: (map['usuarioId'] ?? '').toString(),
      usuarioNombre: (map['usuarioNombre'] ?? '').toString(),
      comentario: (map['comentario'] ?? '').toString(),
      calificacion: (map['calificacion'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ResenaModelo copyWith({
    String? id,
    String? usuarioId,
    String? usuarioNombre,
    String? comentario,
    double? calificacion,
    DateTime? createdAt,
  }) {
    return ResenaModelo(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      usuarioNombre: usuarioNombre ?? this.usuarioNombre,
      comentario: comentario ?? this.comentario,
      calificacion: calificacion ?? this.calificacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
