import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/modelos/libro_modelo.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class FavoritosVista extends StatefulWidget {
  const FavoritosVista({super.key});

  @override
  State<FavoritosVista> createState() => _FavoritosVistaState();
}

class _FavoritosVistaState extends State<FavoritosVista> {
  List<LibroModelo> _libros = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _cargando = true);
    try {
      final favSnap = await FirebaseFirestore.instance
          .collection('favoritos')
          .where('usuarioId', isEqualTo: user.uid)
          .get();

      final librosRef = FirebaseFirestore.instance.collection('libros');
      final libros = <LibroModelo>[];
      for (final doc in favSnap.docs) {
        final libroId = doc.data()['libroId'] as String?;
        if (libroId == null) continue;
        final libroDoc = await librosRef.doc(libroId).get();
        if (libroDoc.exists) {
          libros.add(LibroModelo.fromMap(libroDoc.data()!));
        }
      }
      setState(() => _libros = libros);
    } catch (_) {}
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Mis Favoritos')),
      body: _cargando
          ? const Cargando(
              pantallaCompleta: false,
              mensaje: 'Cargando favoritos...',
            )
          : _libros.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 72,
                    color: Constantes.vinoSoft.withAlpha(128),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No tienes favoritos',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      color: Constantes.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Agrega libros a tus favoritos',
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
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarFavoritos,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                itemCount: _libros.length,
                itemBuilder: (_, index) {
                  final libro = _libros[index];
                  return _TarjetaFavorito(
                    libro: libro,
                    onTap: () => context.go('/libro/${libro.id}'),
                    onQuitarFavorito: () async {
                      await auth.quitarFavorito(libro.id);
                      _cargarFavoritos();
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _TarjetaFavorito extends StatelessWidget {
  final LibroModelo libro;
  final VoidCallback onTap;
  final VoidCallback onQuitarFavorito;

  const _TarjetaFavorito({
    required this.libro,
    required this.onTap,
    required this.onQuitarFavorito,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Constantes.vinoPrimary.withAlpha(25)),
        boxShadow: [
          BoxShadow(
            color: Constantes.vinoDark.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Portada pequeña
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: libro.portadaUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: libro.portadaUrl,
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _placeholder(),
                        errorWidget: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      libro.titulo,
                      style: const TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Constantes.textDark,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      libro.autorNombre,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Constantes.textDark.withAlpha(160),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 13, color: Colors.amber),
                        const SizedBox(width: 3),
                        Text(
                          libro.calificacion.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Constantes.textDark,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '\$${libro.precio.toStringAsFixed(0)} MXN',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Constantes.vinoPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Botón quitar favorito
              GestureDetector(
                onTap: onQuitarFavorito,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
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
      width: 60,
      height: 80,
      color: Colors.grey[100],
      child: const Icon(Icons.book, size: 28, color: Colors.grey),
    );
  }
}
