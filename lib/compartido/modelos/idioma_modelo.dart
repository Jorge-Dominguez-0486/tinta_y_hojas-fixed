class IdiomaModelo {
  final String id;
  final String nombre;
  final String codigo;

  IdiomaModelo({
    required this.id,
    this.nombre = '',
    this.codigo = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
    };
  }

  factory IdiomaModelo.fromMap(Map<String, dynamic> map) {
    return IdiomaModelo(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      codigo: (map['codigo'] ?? '').toString(),
    );
  }

  IdiomaModelo copyWith({
    String? id,
    String? nombre,
    String? codigo,
  }) {
    return IdiomaModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
    );
  }
}
