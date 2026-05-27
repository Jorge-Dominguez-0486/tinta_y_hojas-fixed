import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/pedido_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class MisPedidosVista extends StatefulWidget {
  const MisPedidosVista({super.key});

  @override
  State<MisPedidosVista> createState() => _MisPedidosVistaState();
}

class _MisPedidosVistaState extends State<MisPedidosVista> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<PedidoProvider>().escucharPedidos(user.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pedidoProv = context.watch<PedidoProvider>();
    final formato = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    Color _colorEstado(String estado) {
      switch (estado) {
        case 'pendiente':
          return Colors.orange;
        case 'procesando':
          return Colors.blue;
        case 'entregado':
          return Colors.green;
        case 'cancelado':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Mis Pedidos')),
      body: pedidoProv.cargando
          ? const Cargando(mensaje: 'Cargando pedidos...')
          : pedidoProv.mensajeError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar pedidos',
                          style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, color: Constantes.textDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                          Text(
                            pedidoProv.mensajeError!,
                            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Constantes.textDark.withAlpha(180)),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                context.read<PedidoProvider>().escucharPedidos(user.uid);
                              }
                            },
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Reintentar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Constantes.vinoPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : pedidoProv.pedidos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 80, color: Constantes.vinoSoft.withAlpha(128)),
                            const SizedBox(height: 16),
                            const Text(
                              'No tienes pedidos aún',
                              style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, color: Constantes.textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tus compras aparecerán aquí',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Constantes.textDark.withAlpha(180)),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                  itemCount: pedidoProv.pedidos.length,
                  itemBuilder: (_, index) {
                    final pedido = pedidoProv.pedidos[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Constantes.cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Constantes.vinoSoft.withAlpha(60)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(13),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ExpansionTile(
                        shape: const Border(),
                        collapsedShape: const Border(),
                        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '#${pedido.id.length > 8 ? pedido.id.substring(0, 8).toUpperCase() : pedido.id.toUpperCase()}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Constantes.textDark,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _colorEstado(pedido.estado).withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                pedido.estado[0].toUpperCase() + pedido.estado.substring(1),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _colorEstado(pedido.estado),
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${formato.format(pedido.total)} MXN • ${DateFormat('dd/MM/yy').format(pedido.createdAt)}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Constantes.textDark.withAlpha(150),
                            ),
                          ),
                        ),
                        children: [
                          const Divider(),
                          const SizedBox(height: 4),
                          ...pedido.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: item.portadaUrl.isNotEmpty
                                          ? Image.network(
                                              item.portadaUrl,
                                              width: 36,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 24),
                                            )
                                          : const Icon(Icons.book, size: 24),
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
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Constantes.textDark,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${formato.format(item.precio)} x ${item.cantidad}',
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 11,
                                              color: Constantes.textDark.withAlpha(130),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      formato.format(item.subtotal),
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Constantes.vinoPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          if (pedido.direccion.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, size: 13, color: Constantes.vinoSoft),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Envío: ${pedido.direccion}',
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Constantes.textDark.withAlpha(150)),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pago: ${pedido.metodoPago}',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Constantes.textDark.withAlpha(150),
                                  ),
                                ),
                                Text(
                                  'Total: ${formato.format(pedido.total)} MXN',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Constantes.vinoPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
