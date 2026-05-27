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
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Constantes.vinoDark.withAlpha(16),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
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
            if (libro.stock == 0)
              Container(
                width: double.infinity,
                color: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: const Text(
                  'Agotado',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w600),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Constantes.textDark,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      libro.autorNombre,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        color: Constantes.textDark.withAlpha(140),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            '\$${libro.precio.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Constantes.vinoPrimary,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        if (libro.stock > 0)
                          GestureDetector(
                            onTap: onAgregarCarrito,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Constantes.vinoPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 14),
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
          size: 28,
          color: Constantes.vinoSoft.withAlpha(100),
        ),
      ),
    );
  }
}
