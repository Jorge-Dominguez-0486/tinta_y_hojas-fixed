class CarritoItemModelo {
  final String libroId;
  final String titulo;
  final String portadaUrl;
  final double precio;
  int cantidad;

  CarritoItemModelo({
    required this.libroId,
    this.titulo = '',
    this.portadaUrl = '',
    this.precio = 0.0,
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;

  Map<String, dynamic> toMap() {
    return {
      'libroId': libroId,
      'titulo': titulo,
      'portadaUrl': portadaUrl,
      'precio': precio,
      'cantidad': cantidad,
    };
  }

  factory CarritoItemModelo.fromMap(Map<String, dynamic> map) {
    return CarritoItemModelo(
      libroId: (map['libroId'] ?? '').toString(),
      titulo: (map['titulo'] ?? '').toString(),
      portadaUrl: (map['portadaUrl'] ?? '').toString(),
      precio: (map['precio'] ?? 0).toDouble(),
      cantidad: (map['cantidad'] ?? 1).toInt(),
    );
  }

  CarritoItemModelo copyWith({
    String? libroId,
    String? titulo,
    String? portadaUrl,
    double? precio,
    int? cantidad,
  }) {
    return CarritoItemModelo(
      libroId: libroId ?? this.libroId,
      titulo: titulo ?? this.titulo,
      portadaUrl: portadaUrl ?? this.portadaUrl,
      precio: precio ?? this.precio,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}
