import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinta_y_hojas/compartido/modelos/libro_modelo.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class TarjetaLibro extends StatelessWidget {
  final LibroModelo libro;
  final VoidCallback? onTap;
  final VoidCallback? onAgregarCarrito;

  const TarjetaLibro({
    super.key,
    required this.libro,
    this.onTap,
    this.onAgregarCarrito,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Constantes.cream,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.7,
              child: Hero(
                tag: 'libro_${libro.id}',
                child: libro.portadaUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: libro.portadaUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold, fontSize: 14, color: Constantes.textDark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      libro.autorNombre,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Constantes.vinoSoft),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(libro.calificacion.toStringAsFixed(1), style: const TextStyle(fontSize: 11, color: Constantes.textDark)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${libro.precio.toStringAsFixed(0)} MXN',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Constantes.vinoPrimary),
                        ),
                        if (libro.stock > 0)
                          GestureDetector(
                            onTap: onAgregarCarrito,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Constantes.vinoPrimary, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Agregar', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          )
                        else
                          const Text('Agotado', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(child: Icon(Icons.book, size: 40, color: Colors.grey)),
    );
  }
}
