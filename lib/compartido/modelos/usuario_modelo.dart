import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModelo {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String rol;
  final String fotoUrl;
  final DateTime createdAt;

  UsuarioModelo({
    required this.id,
    this.nombre = '',
    this.correo = '',
    this.telefono = '',
    this.rol = 'cliente',
    this.fotoUrl = '',
    required this.createdAt,
  });

  bool get esAdmin => rol == 'admin';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'rol': rol,
      'fotoUrl': fotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UsuarioModelo.fromMap(Map<String, dynamic> map) {
    return UsuarioModelo(
      id: (map['id'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      correo: (map['correo'] ?? '').toString(),
      telefono: (map['telefono'] ?? '').toString(),
      rol: (map['rol'] ?? 'cliente').toString(),
      fotoUrl: (map['fotoUrl'] ?? '').toString(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  UsuarioModelo copyWith({
    String? id,
    String? nombre,
    String? correo,
    String? telefono,
    String? rol,
    String? fotoUrl,
    DateTime? createdAt,
  }) {
    return UsuarioModelo(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      rol: rol ?? this.rol,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
