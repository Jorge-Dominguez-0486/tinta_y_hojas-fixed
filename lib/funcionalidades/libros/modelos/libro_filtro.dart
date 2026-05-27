class LibroFiltro {
  final String? categoria;
  final double? precioMinimo;
  final double? precioMaximo;
  final String? busqueda;

  LibroFiltro({
    this.categoria,
    this.precioMinimo,
    this.precioMaximo,
    this.busqueda,
  });

  LibroFiltro copyWith({
    String? categoria,
    double? precioMinimo,
    double? precioMaximo,
    String? busqueda,
  }) {
    return LibroFiltro(
      categoria: categoria ?? this.categoria,
      precioMinimo: precioMinimo ?? this.precioMinimo,
      precioMaximo: precioMaximo ?? this.precioMaximo,
      busqueda: busqueda ?? this.busqueda,
    );
  }
}
