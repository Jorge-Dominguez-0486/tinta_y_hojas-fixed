import 'package:flutter/material.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class DialogoConfirmacion extends StatelessWidget {
  final String titulo;
  final String mensaje;
  final String textoConfirmar;
  final String textoCancelar;
  final VoidCallback? onConfirmar;
  final bool peligroso;

  const DialogoConfirmacion({
    super.key,
    required this.titulo,
    required this.mensaje,
    this.textoConfirmar = 'Confirmar',
    this.textoCancelar = 'Cancelar',
    this.onConfirmar,
    this.peligroso = false,
  });

  static Future<bool?> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoConfirmar = 'Confirmar',
    String textoCancelar = 'Cancelar',
    bool peligroso = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DialogoConfirmacion(
        titulo: titulo,
        mensaje: mensaje,
        textoConfirmar: textoConfirmar,
        textoCancelar: textoCancelar,
        peligroso: peligroso,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(titulo, style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold)),
      content: Text(mensaje, style: const TextStyle(fontFamily: 'Inter', fontSize: 14)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: Constantes.vinoSoft,
            side: const BorderSide(color: Constantes.vinoSoft),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(textoCancelar, style: const TextStyle(fontFamily: 'Inter')),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirmar?.call();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: peligroso ? Colors.red : Constantes.vinoPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(textoConfirmar, style: const TextStyle(fontFamily: 'Inter')),
        ),
      ],
    );
  }
}
