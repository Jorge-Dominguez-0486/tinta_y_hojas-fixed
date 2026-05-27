import 'package:flutter/material.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class ResenasVista extends StatelessWidget {
  final String? libroId;

  const ResenasVista({super.key, this.libroId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reseñas'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.rate_review_outlined, size: 64, color: Constantes.vinoSoft.withAlpha(128)),
            const SizedBox(height: 16),
            Text(
              'Próximamente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'La sección de reseñas estará disponible pronto.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
