class EditorialModelo {
  final String id;
  final String nombre;
  final String pais;
  final String sitioWeb;

  EditorialModelo({
    required this.id,
    this.nombre = '',
    this.pais = '',
    this.sitioWeb = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'pais': pais,
      'sitioWeb': sitioWeb,
    };
  }

  factory EditorialModelo.fromMap(Map<String, dynamic> map) {
    return EditorialModelo(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      pais: (map['pais'] ?? '').toString(),
      sitioWeb: (map['sitioWeb'] ?? '').toString(),
    );
  }

  EditorialModelo copyWith({
    String? id,
    String? nombre,
    String? pais,
    String? sitioWeb,
  }) {
    return EditorialModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      pais: pais ?? this.pais,
      sitioWeb: sitioWeb ?? this.sitioWeb,
    );
  }
}
