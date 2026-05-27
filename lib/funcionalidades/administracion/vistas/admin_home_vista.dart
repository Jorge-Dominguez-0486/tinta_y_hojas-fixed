import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class AdminHomeVista extends StatefulWidget {
  const AdminHomeVista({super.key});

  @override
  State<AdminHomeVista> createState() => _AdminHomeVistaState();
}

class _AdminHomeVistaState extends State<AdminHomeVista> {
  @override
  void initState() {
    super.initState();
    context.read<AdminProvider>().cargarDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final admin = context.watch<AdminProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Constantes.beige,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
      ),
      drawer: Drawer(
        backgroundColor: Constantes.cream,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Constantes.vinoDark),
              accountName: Text(
                auth.usuarioActual?.nombre ?? 'Admin',
                style: const TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
              ),
              accountEmail: const Text('Panel de Administración'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Constantes.cream,
                child: Text(
                  (auth.usuarioActual?.nombre.isNotEmpty == true)
                      ? auth.usuarioActual!.nombre[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(fontSize: 28, color: Constantes.vinoDark, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _itemDrawer(Icons.dashboard, 'Dashboard', () {
              Navigator.pop(context);
            }),
            _itemDrawer(Icons.menu_book, 'Libros', () {
              Navigator.pop(context);
              context.go('/admin/libros');
            }),
            _itemDrawer(Icons.people, 'Usuarios', () {
              Navigator.pop(context);
              context.go('/admin/usuarios');
            }),
            _itemDrawer(Icons.receipt_long, 'Pedidos', () {
              Navigator.pop(context);
              context.go('/admin/pedidos');
            }),
            _itemDrawer(Icons.category, 'Categorías', () {
              Navigator.pop(context);
              context.go('/admin/categorias');
            }),
            _itemDrawer(Icons.edit, 'Autores', () {
              Navigator.pop(context);
              context.go('/admin/autores');
            }),
            _itemDrawer(Icons.business, 'Editoriales', () {
              Navigator.pop(context);
              context.go('/admin/editoriales');
            }),
            _itemDrawer(Icons.language, 'Idiomas', () {
              Navigator.pop(context);
              context.go('/admin/idiomas');
            }),
            _itemDrawer(Icons.local_shipping, 'Proveedores', () {
              Navigator.pop(context);
              context.go('/admin/proveedores');
            }),
            const Divider(color: Constantes.vinoSoft),
            _itemDrawer(Icons.visibility, 'Vista de Cliente', () {
              Navigator.pop(context);
              context.go('/home');
            }),
          ],
        ),
      ),
      body: admin.cargando
          ? const Cargando(pantallaCompleta: false, mensaje: 'Cargando panel...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Administración',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Constantes.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gestiona tu tienda',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Constantes.textDark.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    children: [
                      _TarjetaAcceso(
                        titulo: 'Libros',
                        subtitulo: '${admin.totalLibros}',
                        icono: Icons.menu_book,
                        color: Constantes.vinoPrimary,
                        onTap: () => context.go('/admin/libros'),
                      ),
                      _TarjetaAcceso(
                        titulo: 'Usuarios',
                        subtitulo: '${admin.totalUsuarios}',
                        icono: Icons.people,
                        color: Constantes.vinoSoft,
                        onTap: () => context.go('/admin/usuarios'),
                      ),
                      _TarjetaAcceso(
                        titulo: 'Pedidos Pendientes',
                        subtitulo: '${admin.pedidosPendientes}',
                        icono: Icons.receipt_long,
                        color: admin.pedidosPendientes > 0 ? Colors.orange : Constantes.vinoDark,
                        onTap: () => context.go('/admin/pedidos'),
                      ),
                      _TarjetaAcceso(
                        titulo: 'Categorías',
                        subtitulo: '',
                        icono: Icons.category,
                        color: Constantes.vinoDark,
                        onTap: () => context.go('/admin/categorias'),
                      ),
                      _TarjetaAcceso(
                        titulo: 'Autores',
                        subtitulo: '',
                        icono: Icons.edit,
                        color: Constantes.goldSoft,
                        onTap: () => context.go('/admin/autores'),
                      ),
                      _TarjetaAcceso(
                        titulo: 'Editoriales',
                        subtitulo: '',
                        icono: Icons.business,
                        color: Constantes.vinoSoft,
                        onTap: () => context.go('/admin/editoriales'),
                      ),
                      _TarjetaAcceso(
                        titulo: 'Idiomas',
                        subtitulo: '',
                        icono: Icons.language,
                        color: Constantes.vinoPrimary,
                        onTap: () => context.go('/admin/idiomas'),
                      ),
                      _TarjetaAcceso(
                        titulo: 'Proveedores',
                        subtitulo: '',
                        icono: Icons.local_shipping,
                        color: Constantes.goldSoft,
                        onTap: () => context.go('/admin/proveedores'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _itemDrawer(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Constantes.vinoSoft),
      title: Text(text, style: const TextStyle(fontFamily: 'Inter', color: Constantes.textDark)),
      onTap: onTap,
    );
  }
}

class _TarjetaAcceso extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;
  final VoidCallback onTap;

  const _TarjetaAcceso({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Constantes.cream,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(26),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icono, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                subtitulo.isNotEmpty ? subtitulo : '',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Constantes.textDark,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
