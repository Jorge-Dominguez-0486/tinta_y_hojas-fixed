class CategoriaModelo {
  final String id;
  final String nombre;
  final String icono;

  CategoriaModelo({
    required this.id,
    this.nombre = '',
    this.icono = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'icono': icono,
    };
  }

  factory CategoriaModelo.fromMap(Map<String, dynamic> map) {
    return CategoriaModelo(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      icono: (map['icono'] ?? '').toString(),
    );
  }

  CategoriaModelo copyWith({
    String? id,
    String? nombre,
    String? icono,
  }) {
    return CategoriaModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
    );
  }
}
