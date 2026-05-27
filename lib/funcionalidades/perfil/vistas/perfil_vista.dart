import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class PerfilVista extends StatelessWidget {
  const PerfilVista({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.usuarioActual;

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Stack(
              children: [
                CircleAvatar(
                  radius: 56,
                  backgroundColor: Constantes.vinoSoft,
                  backgroundImage: (user != null && user.fotoUrl.isNotEmpty)
                      ? NetworkImage(user.fotoUrl)
                      : null,
                  child: (user == null || user.fotoUrl.isEmpty)
                      ? Text(
                          user != null && user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              user?.nombre ?? 'Usuario',
              style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.bold, color: Constantes.textDark),
            ),
            const SizedBox(height: 4),
            Text(
              user?.correo ?? '',
              style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Constantes.textDark.withAlpha(180)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/editar-perfil'),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Editar perfil', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Constantes.vinoPrimary,
                  side: const BorderSide(color: Constantes.vinoPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _cardAcceso(
              context,
              icon: Icons.receipt_long,
              titulo: 'Mis Pedidos',
              subtitulo: 'Historial de compras',
              onTap: () => context.go('/mis-pedidos'),
            ),
            const SizedBox(height: 10),
            _cardAcceso(
              context,
              icon: Icons.favorite,
              titulo: 'Mis Favoritos',
              subtitulo: 'Libros guardados',
              onTap: () => context.go('/favoritos'),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Constantes.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Constantes.vinoSoft.withAlpha(60)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Información', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 16, fontWeight: FontWeight.bold, color: Constantes.textDark)),
                  const SizedBox(height: 12),
                  if (user?.telefono.isNotEmpty == true) ...[
                    _infoFila(Icons.phone, 'Teléfono', user!.telefono),
                    const SizedBox(height: 8),
                  ],
                  _infoFila(Icons.calendar_today, 'Miembro desde', user?.createdAt != null ? _formatearFecha(user!.createdAt) : '—'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.cerrarSesion();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Cerrar sesión', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[600],
                  side: BorderSide(color: Colors.red[300]!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    const meses = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
    return '${fecha.day} de ${meses[fecha.month - 1]}, ${fecha.year}';
  }

  Widget _cardAcceso(BuildContext context, {required IconData icon, required String titulo, required String subtitulo, required VoidCallback onTap}) {
    return Material(
      color: Constantes.cream,
      borderRadius: BorderRadius.circular(12),
      elevation: 1,
      shadowColor: Colors.black.withAlpha(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Constantes.vinoSoft.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: Constantes.vinoPrimary, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w600, color: Constantes.textDark)),
                    Text(subtitulo, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Constantes.textDark.withAlpha(150))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Constantes.vinoSoft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoFila(IconData icon, String label, String valor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Constantes.vinoSoft),
        const SizedBox(width: 10),
        Text('$label: ', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Constantes.textDark.withAlpha(150))),
        Expanded(child: Text(valor, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Constantes.textDark))),
      ],
    );
  }
}
