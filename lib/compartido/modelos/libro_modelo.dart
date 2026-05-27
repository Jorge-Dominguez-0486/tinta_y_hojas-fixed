import 'package:cloud_firestore/cloud_firestore.dart';

class LibroModelo {
  final String id;
  final String titulo;
  final String descripcion;
  final String autorId;
  final String autorNombre;
  final String categoriaId;
  final String categoriaNombre;
  final String editorialId;
  final String editorialNombre;
  final String idiomaId;
  final String idiomaNombre;
  final double precio;
  final int stock;
  final String portadaUrl;
  final double calificacion;
  final int totalResenas;
  final bool destacado;
  final DateTime createdAt;

  LibroModelo({
    required this.id,
    this.titulo = '',
    this.descripcion = '',
    this.autorId = '',
    this.autorNombre = '',
    this.categoriaId = '',
    this.categoriaNombre = '',
    this.editorialId = '',
    this.editorialNombre = '',
    this.idiomaId = '',
    this.idiomaNombre = '',
    this.precio = 0.0,
    this.stock = 0,
    this.portadaUrl = '',
    this.calificacion = 0.0,
    this.totalResenas = 0,
    this.destacado = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'autorId': autorId,
      'autorNombre': autorNombre,
      'categoriaId': categoriaId,
      'categoriaNombre': categoriaNombre,
      'editorialId': editorialId,
      'editorialNombre': editorialNombre,
      'idiomaId': idiomaId,
      'idiomaNombre': idiomaNombre,
      'precio': precio,
      'stock': stock,
      'portadaUrl': portadaUrl,
      'calificacion': calificacion,
      'totalResenas': totalResenas,
      'destacado': destacado,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory LibroModelo.fromMap(Map<String, dynamic> map) {
    return LibroModelo(
      id: (map['id'] ?? '').toString(),
      titulo: (map['titulo'] ?? '').toString(),
      descripcion: (map['descripcion'] ?? '').toString(),
      autorId: (map['autorId'] ?? '').toString(),
      autorNombre: (map['autorNombre'] ?? '').toString(),
      categoriaId: (map['categoriaId'] ?? '').toString(),
      categoriaNombre: (map['categoriaNombre'] ?? '').toString(),
      editorialId: (map['editorialId'] ?? '').toString(),
      editorialNombre: (map['editorialNombre'] ?? '').toString(),
      idiomaId: (map['idiomaId'] ?? '').toString(),
      idiomaNombre: (map['idiomaNombre'] ?? '').toString(),
      precio: (map['precio'] ?? 0).toDouble(),
      stock: (map['stock'] ?? 0).toInt(),
      portadaUrl: (map['portadaUrl'] ?? '').toString(),
      calificacion: (map['calificacion'] ?? 0.0).toDouble(),
      totalResenas: (map['totalResenas'] ?? 0).toInt(),
      destacado: map['destacado'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  LibroModelo copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    String? autorId,
    String? autorNombre,
    String? categoriaId,
    String? categoriaNombre,
    String? editorialId,
    String? editorialNombre,
    String? idiomaId,
    String? idiomaNombre,
    double? precio,
    int? stock,
    String? portadaUrl,
    double? calificacion,
    int? totalResenas,
    bool? destacado,
    DateTime? createdAt,
  }) {
    return LibroModelo(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      autorId: autorId ?? this.autorId,
      autorNombre: autorNombre ?? this.autorNombre,
      categoriaId: categoriaId ?? this.categoriaId,
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
      editorialId: editorialId ?? this.editorialId,
      editorialNombre: editorialNombre ?? this.editorialNombre,
      idiomaId: idiomaId ?? this.idiomaId,
      idiomaNombre: idiomaNombre ?? this.idiomaNombre,
      precio: precio ?? this.precio,
      stock: stock ?? this.stock,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      calificacion: calificacion ?? this.calificacion,
      totalResenas: totalResenas ?? this.totalResenas,
      destacado: destacado ?? this.destacado,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
