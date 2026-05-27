import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/carrito_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class CheckoutVista extends StatefulWidget {
  const CheckoutVista({super.key});

  @override
  State<CheckoutVista> createState() => _CheckoutVistaState();
}

class _CheckoutVistaState extends State<CheckoutVista> {
  String _metodoPago = 'Tarjeta de crédito';
  bool _confirmando = false;
  final _direccionCtrl = TextEditingController();

  final _metodosPago = [
    'Tarjeta de crédito',
    'Efectivo al entregar',
    'Transferencia',
  ];

  @override
  void dispose() {
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarCompra() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _confirmando = true);

    try {
      await context.read<CarritoProvider>().confirmarPedido(
            usuarioId: user.uid,
            metodoPago: _metodoPago,
            direccion: _direccionCtrl.text.trim(),
          );

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.check_circle, size: 72, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                '¡Compra exitosa!',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constantes.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu pedido ha sido registrado correctamente.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: Constantes.textDark.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Constantes.vinoPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Volver al inicio'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pedido: $e'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _confirmando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final formato = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    if (carrito.estaVacio) {
      return Scaffold(
        drawer: const DrawerPrincipal(),
        appBar: AppBar(title: const Text('Checkout')),
        body: const Center(child: Text('El carrito está vacío')),
      );
    }

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Checkout')),
      body: _confirmando
          ? const Cargando(mensaje: 'Procesando pedido...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen del pedido',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constantes.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...carrito.items.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Constantes.cream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Constantes.vinoSoft.withAlpha(60)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: item.portadaUrl.isNotEmpty
                                  ? Image.network(
                                      item.portadaUrl,
                                      width: 40,
                                      height: 56,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 28),
                                    )
                                  : const Icon(Icons.book, size: 28),
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
                                  const SizedBox(height: 2),
                                  Text(
                                    '${formato.format(item.precio)} x ${item.cantidad}',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Constantes.textDark.withAlpha(150),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formato.format(item.subtotal),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Constantes.vinoPrimary,
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Constantes.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Constantes.vinoSoft.withAlpha(100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Constantes.textDark,
                          ),
                        ),
                        Text(
                          '${formato.format(carrito.total)} MXN',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Constantes.vinoPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Método de pago',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constantes.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._metodosPago.map((metodo) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: _metodoPago == metodo
                              ? Constantes.vinoPrimary.withAlpha(30)
                              : Constantes.cream,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _metodoPago == metodo
                                ? Constantes.vinoPrimary
                                : Constantes.vinoSoft.withAlpha(80),
                          ),
                        ),
                        child: RadioListTile<String>(
                          title: Text(
                            metodo,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              color: Constantes.textDark,
                            ),
                          ),
                          value: metodo,
                          groupValue: _metodoPago,
                          activeColor: Constantes.vinoPrimary,
                          onChanged: (v) => setState(() => _metodoPago = v!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),
                  const SizedBox(height: 24),
                  const Text(
                    'Dirección de envío',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Constantes.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _direccionCtrl,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      hintText: 'Calle, número, colonia, ciudad, código postal',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      filled: true,
                      fillColor: Constantes.cream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _confirmando ? null : _confirmarCompra,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Confirmar compra',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Constantes.vinoPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
