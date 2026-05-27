import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/pedido_provider.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class DrawerPrincipal extends StatelessWidget {
  const DrawerPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Drawer(
      backgroundColor: Constantes.cream,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: Constantes.vinoDark),
            accountName: Text(
              auth.usuarioActual?.nombre ?? 'Usuario',
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(auth.usuarioActual?.correo ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Constantes.cream,
              backgroundImage:
                  (auth.usuarioActual != null &&
                      auth.usuarioActual!.fotoUrl.isNotEmpty)
                  ? NetworkImage(auth.usuarioActual!.fotoUrl)
                  : null,
              child:
                  (auth.usuarioActual == null ||
                      auth.usuarioActual!.fotoUrl.isEmpty)
                  ? Text(
                      auth.usuarioActual != null &&
                              auth.usuarioActual!.nombre.isNotEmpty
                          ? auth.usuarioActual!.nombre[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 28,
                        color: Constantes.vinoDark,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          _item(Icons.home, 'Inicio', () {
            Navigator.pop(context);
            context.go('/home');
          }),
          _item(Icons.menu_book, 'Catálogo', () {
            Navigator.pop(context);
            context.go('/home');
          }),
          _item(Icons.shopping_cart_outlined, 'Mi Carrito', () {
            Navigator.pop(context);
            context.go('/carrito');
          }),
          _item(Icons.favorite_border, 'Mis Favoritos', () {
            Navigator.pop(context);
            context.go('/favoritos');
          }),
          _item(Icons.receipt_long, 'Mis Pedidos', () {
            Navigator.pop(context);
            context.go('/mis-pedidos');
          }),
          _item(Icons.person_outline, 'Mi Perfil', () {
            Navigator.pop(context);
            context.go('/perfil');
          }),
          if (auth.esAdmin) ...[
            const Divider(color: Constantes.vinoSoft),
            _item(Icons.settings, 'Panel de Administración', () {
              Navigator.pop(context);
              context.go('/admin');
            }),
          ],
          const Divider(color: Constantes.vinoSoft),
          _item(Icons.logout, 'Cerrar Sesión', () async {
            Navigator.pop(context);
            // Limpiar pedidos en memoria antes de cerrar sesión
            if (context.mounted) {
              context.read<PedidoProvider>().limpiar();
            }
            await auth.cerrarSesion();
            if (context.mounted) context.go('/login');
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String text, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? Constantes.vinoSoft),
      title: Text(
        text,
        style: TextStyle(
          fontFamily: 'Inter',
          color: color ?? Constantes.textDark,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
