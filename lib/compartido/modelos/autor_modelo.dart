class AutorModelo {
  final String id;
  final String nombre;
  final String biografia;
  final String fotoUrl;

  AutorModelo({
    required this.id,
    this.nombre = '',
    this.biografia = '',
    this.fotoUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'biografia': biografia,
      'fotoUrl': fotoUrl,
    };
  }

  factory AutorModelo.fromMap(Map<String, dynamic> map) {
    return AutorModelo(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      biografia: (map['biografia'] ?? '').toString(),
      fotoUrl: (map['fotoUrl'] ?? '').toString(),
    );
  }

  AutorModelo copyWith({
    String? id,
    String? nombre,
    String? biografia,
    String? fotoUrl,
  }) {
    return AutorModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      biografia: biografia ?? this.biografia,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}
