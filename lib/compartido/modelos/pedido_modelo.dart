import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinta_y_hojas/compartido/modelos/carrito_item_modelo.dart';

class PedidoModelo {
  final String id;
  final String usuarioId;
  final List<CarritoItemModelo> items;
  final double subtotal;
  final double total;
  final String estado;
  final String metodoPago;
  final DateTime createdAt;

  PedidoModelo({
    required this.id,
    required this.usuarioId,
    this.items = const [],
    this.subtotal = 0.0,
    this.total = 0.0,
    this.estado = 'pendiente',
    this.metodoPago = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'total': total,
      'estado': estado,
      'metodoPago': metodoPago,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory PedidoModelo.fromMap(Map<String, dynamic> map) {
    return PedidoModelo(
      id: (map['id'] ?? '').toString(),
      usuarioId: (map['usuarioId'] ?? '').toString(),
      items: (map['items'] as List<dynamic>?)
              ?.map((item) =>
                  CarritoItemModelo.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
      estado: (map['estado'] ?? 'pendiente').toString(),
      metodoPago: (map['metodoPago'] ?? '').toString(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  PedidoModelo copyWith({
    String? id,
    String? usuarioId,
    List<CarritoItemModelo>? items,
    double? subtotal,
    double? total,
    String? estado,
    String? metodoPago,
    DateTime? createdAt,
  }) {
    return PedidoModelo(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      total: total ?? this.total,
      estado: estado ?? this.estado,
      metodoPago: metodoPago ?? this.metodoPago,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
