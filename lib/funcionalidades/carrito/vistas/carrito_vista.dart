import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/carrito_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/widgets/tarjeta_carrito_item.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class CarritoVista extends StatelessWidget {
  const CarritoVista({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final formato = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(
        title: Text(
          carrito.estaVacio
              ? 'Mi Carrito'
              : 'Mi Carrito (${carrito.cantidadItems})',
        ),
        actions: [
          if (!carrito.estaVacio)
            TextButton(
              onPressed: () => carrito.limpiarCarrito(),
              child: const Text('Vaciar', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: carrito.estaVacio
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Constantes.vinoSoft.withAlpha(128)),
                  const SizedBox(height: 16),
                  const Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      color: Constantes.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega libros para comenzar',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Constantes.textDark.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.menu_book),
                    label: const Text('Explorar libros'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constantes.vinoPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: carrito.items.length,
                    itemBuilder: (_, index) {
                      final item = carrito.items[index];
                      return TarjetaCarritoItem(
                        item: item,
                        onAumentar: () => carrito.aumentarCantidad(item.libroId),
                        onDisminuir: () => carrito.disminuirCantidad(item.libroId),
                        onEliminar: () => carrito.eliminar(item.libroId),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(26),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => context.go('/home'),
                                icon: const Icon(Icons.arrow_back, size: 18),
                                label: const Text(
                                  'Seguir comprando',
                                  style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Constantes.vinoSoft,
                                  side: BorderSide(color: Constantes.vinoSoft.withAlpha(100)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () => context.go('/checkout'),
                                icon: const Icon(Icons.shopping_cart_checkout, size: 18),
                                label: Text(
                                  'Pagar ${formato.format(carrito.total)} MXN',
                                  style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Constantes.vinoPrimary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }
}
