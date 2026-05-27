import 'package:flutter/material.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class Cargando extends StatelessWidget {
  final String? mensaje;
  final bool pantallaCompleta;

  const Cargando({
    super.key,
    this.mensaje,
    this.pantallaCompleta = true,
  });

  @override
  Widget build(BuildContext context) {
    final contenido = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Constantes.vinoPrimary),
          if (mensaje != null) ...[
            const SizedBox(height: 16),
            Text(mensaje!, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Constantes.textDark)),
          ],
        ],
      ),
    );

    if (pantallaCompleta) {
      return Scaffold(
        backgroundColor: Constantes.beige,
        body: contenido,
      );
    }

    return contenido;
  }
}
