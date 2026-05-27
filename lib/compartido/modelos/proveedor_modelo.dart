class ProveedorModelo {
  final String id;
  final String nombre;
  final String telefono;
  final String correo;
  final String direccion;

  ProveedorModelo({
    required this.id,
    this.nombre = '',
    this.telefono = '',
    this.correo = '',
    this.direccion = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'telefono': telefono,
      'correo': correo,
      'direccion': direccion,
    };
  }

  factory ProveedorModelo.fromMap(Map<String, dynamic> map) {
    return ProveedorModelo(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      telefono: (map['telefono'] ?? '').toString(),
      correo: (map['correo'] ?? '').toString(),
      direccion: (map['direccion'] ?? '').toString(),
    );
  }

  ProveedorModelo copyWith({
    String? id,
    String? nombre,
    String? telefono,
    String? correo,
    String? direccion,
  }) {
    return ProveedorModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      correo: correo ?? this.correo,
      direccion: direccion ?? this.direccion,
    );
  }
}
