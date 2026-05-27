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
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Eliminar'),
          content: const Text('¿Eliminar este libro del carrito?'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onEliminar?.call(),
      child: Card(
        color: Constantes.cream,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.portadaUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.portadaUrl,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 60,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.book, size: 28, color: Colors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 60,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.book, size: 28, color: Colors.grey),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 80,
                        color: Colors.grey[200],
                        child: const Icon(Icons.book, size: 28, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titulo,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 2),
                    Text(
                      'Subtotal: \$${item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Constantes.vinoPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  InkWell(
                    onTap: onAumentar,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Constantes.vinoPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${item.cantidad}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onDisminuir,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Constantes.vinoSoft.withAlpha(150),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onEliminar,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
