import 'package:flutter/material.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class BotonPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? colorFondo;
  final Color? colorTexto;
  final double? ancho;
  final IconData? icono;

  const BotonPrimario({
    super.key,
    required this.texto,
    this.onPressed,
    this.isLoading = false,
    this.colorFondo,
    this.colorTexto,
    this.ancho,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final deshabilitado = onPressed == null || isLoading;

    return Opacity(
      opacity: deshabilitado ? 0.6 : 1.0,
      child: SizedBox(
        width: ancho ?? double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: deshabilitado ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorFondo ?? Constantes.vinoPrimary,
            foregroundColor: colorTexto ?? Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icono != null) ...[
                      Icon(icono, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(texto),
                  ],
                ),
        ),
      ),
    );
  }
}
