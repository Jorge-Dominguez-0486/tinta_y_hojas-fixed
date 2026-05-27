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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Constantes.vinoDark.withAlpha(22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada con ratio fijo y badge de stock
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 0.72,
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
                // Badge agotado
                if (libro.stock == 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Agotado',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Info del libro
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(9, 8, 9, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Constantes.textDark,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      libro.autorNombre,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Constantes.textDark.withAlpha(160),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Estrellas
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          libro.calificacion.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 11,
                            color: Constantes.textDark.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Precio + botón agregar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${libro.precio.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Constantes.vinoPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        if (libro.stock > 0)
                          GestureDetector(
                            onTap: onAgregarCarrito,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Constantes.vinoPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
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
      color: const Color(0xFFF0EBE3),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 36,
          color: Constantes.vinoSoft.withAlpha(120),
        ),
      ),
    );
  }
}
