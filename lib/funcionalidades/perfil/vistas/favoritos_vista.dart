import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/componentes/tarjeta_libro.dart';
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
          ? const Cargando(pantallaCompleta: false, mensaje: 'Cargando favoritos...')
          : _libros.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 72, color: Constantes.vinoSoft.withAlpha(128)),
                      const SizedBox(height: 16),
                      const Text('No tienes favoritos', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 20, color: Constantes.textDark)),
                      const SizedBox(height: 8),
                      Text('Agrega libros a tus favoritos', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Constantes.textDark.withAlpha(180))),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.go('/home'),
                        icon: const Icon(Icons.menu_book),
                        label: const Text('Explorar libros'),
                        style: ElevatedButton.styleFrom(backgroundColor: Constantes.vinoPrimary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarFavoritos,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _libros.length,
                    itemBuilder: (_, index) {
                      final libro = _libros[index];
                      return Stack(
                        children: [
                          TarjetaLibro(
                            libro: libro,
                            onTap: () => context.go('/libro/${libro.id}'),
                            onAgregarCarrito: () {},
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () async {
                                await auth.quitarFavorito(libro.id);
                                _cargarFavoritos();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
                                child: const Icon(Icons.favorite, color: Colors.red, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
    );
  }
}
