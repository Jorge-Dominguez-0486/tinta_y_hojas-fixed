class CarritoResumen {
  final int cantidadItems;
  final double subtotal;
  final double? descuento;
  final double total;

  CarritoResumen({
    required this.cantidadItems,
    required this.subtotal,
    this.descuento,
    required this.total,
  });
}
