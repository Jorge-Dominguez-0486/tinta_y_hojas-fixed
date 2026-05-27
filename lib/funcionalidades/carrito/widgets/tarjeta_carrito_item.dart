import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinta_y_hojas/compartido/modelos/carrito_item_modelo.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class TarjetaCarritoItem extends StatelessWidget {
  final CarritoItemModelo item;
  final VoidCallback? onAumentar;
  final VoidCallback? onDisminuir;
  final VoidCallback? onEliminar;

  const TarjetaCarritoItem({
    super.key,
    required this.item,
    this.onAumentar,
    this.onDisminuir,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.libroId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar'),
          content: const Text('¿Eliminar este libro del carrito?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onEliminar?.call(),
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Constantes.vinoPrimary.withAlpha(30),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.portadaUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.portadaUrl,
                        width: 65,
                        height: 88,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 12),
              // Info del libro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Constantes.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.precio.toStringAsFixed(2)} c/u',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Constantes.vinoSoft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Fila inferior: subtotal + controles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Subtotal
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Subtotal',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: Constantes.vinoSoft,
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Constantes.vinoPrimary,
                              ),
                            ),
                          ],
                        ),
                        // Controles de cantidad en fila horizontal
                        Row(
                          children: [
                            // Botón eliminar
                            GestureDetector(
                              onTap: onEliminar,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red[400],
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Contador con estilo pill
                            Container(
                              decoration: BoxDecoration(
                                color: Constantes.beige,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Constantes.vinoPrimary.withAlpha(50),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: onDisminuir,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      child: const Icon(
                                        Icons.remove,
                                        size: 15,
                                        color: Constantes.vinoPrimary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 28,
                                    child: Text(
                                      '${item.cantidad}',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Constantes.textDark,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: onAumentar,
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        color: Constantes.vinoPrimary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 65,
      height: 88,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.book, size: 28, color: Colors.grey),
    );
  }
}
