import 'package:flutter/material.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final String? textoBoton;
  final VoidCallback? onBotonPressed;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.textoBoton,
    this.onBotonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 80, color: Constantes.vinoSoft.withAlpha(128)),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 20, color: Constantes.textDark),
              textAlign: TextAlign.center,
            ),
            if (subtitulo != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitulo!,
                style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Constantes.textDark.withAlpha(180)),
                textAlign: TextAlign.center,
              ),
            ],
            if (textoBoton != null && onBotonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onBotonPressed,
                icon: const Icon(Icons.explore),
                label: Text(textoBoton!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constantes.vinoPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
