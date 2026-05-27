import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:uuid/uuid.dart';
import 'package:tinta_y_hojas/funcionalidades/libros/proveedores/libro_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/carrito_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/resena_modelo.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class DetalleLibroVista extends StatefulWidget {
  final String libroId;
  const DetalleLibroVista({super.key, required this.libroId});

  @override
  State<DetalleLibroVista> createState() => _DetalleLibroVistaState();
}

class _DetalleLibroVistaState extends State<DetalleLibroVista> {
  bool _agregado = false;
  int _estrellas = 0;
  final _comentarioCtrl = TextEditingController();
  late final CollectionReference _resenasRef;

  @override
  void initState() {
    super.initState();
    _resenasRef = FirebaseFirestore.instance.collection('libros').doc(widget.libroId).collection('resenas');
  }

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _publicarResena() async {
    final user = FirebaseAuth.instance.currentUser;
    final auth = context.read<AuthProvider>();
    if (user == null || _estrellas == 0) return;

    final resenaId = const Uuid().v4();
    final nombre = auth.usuarioActual?.nombre ?? 'Usuario';

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final libroRef = FirebaseFirestore.instance.collection('libros').doc(widget.libroId);
        final libroSnap = await transaction.get(libroRef);
        if (!libroSnap.exists) return;

        final libroData = libroSnap.data()!;
        final totalActual = (libroData['totalResenas'] ?? 0) as int;
        final califActual = (libroData['calificacion'] ?? 0.0).toDouble();
        final nuevoTotal = totalActual + 1;
        final nuevaCalif = ((califActual * totalActual) + _estrellas) / nuevoTotal;

        transaction.set(_resenasRef.doc(resenaId), {
          'id': resenaId,
          'usuarioId': user.uid,
          'usuarioNombre': nombre,
          'comentario': _comentarioCtrl.text.trim(),
          'calificacion': _estrellas.toDouble(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.update(libroRef, {
          'totalResenas': nuevoTotal,
          'calificacion': double.parse(nuevaCalif.toStringAsFixed(1)),
        });
      });

      _comentarioCtrl.clear();
      setState(() => _estrellas = 0);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reseña publicada'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al publicar: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final libro = context.watch<LibroProvider>().obtenerPorId(widget.libroId);
    final auth = context.watch<AuthProvider>();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (libro == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final noStock = libro.stock <= 0;
    final esFavorito = auth.esFavorito(widget.libroId);

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(
        title: Text(libro.titulo, style: const TextStyle(fontSize: 16)),
        actions: [
          IconButton(
            icon: Icon(esFavorito ? Icons.favorite : Icons.favorite_border, color: esFavorito ? Colors.red : Colors.white),
            onPressed: () => auth.toggleFavorito(widget.libroId, libro),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del libro - fondo oscuro con imagen completa centrada
            Container(
              width: double.infinity,
              height: 300,
              color: const Color(0xFF1a0a0a),
              child: libro.portadaUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: libro.portadaUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.white54)),
                      errorWidget: (_, __, ___) => const Center(child: Icon(Icons.book, size: 80, color: Colors.white30)),
                    )
                  : const Center(child: Icon(Icons.book, size: 80, color: Colors.white30)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(libro.titulo, style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.bold, color: Constantes.textDark)),
                  const SizedBox(height: 4),
                  Text(libro.autorNombre, style: const TextStyle(fontFamily: 'Inter', fontSize: 15, color: Constantes.vinoSoft)),
                  const SizedBox(height: 12),
                  Row(children: [
                    if (libro.editorialNombre.isNotEmpty) ...[_infoChip(Icons.business, libro.editorialNombre), const SizedBox(width: 8)],
                    if (libro.idiomaNombre.isNotEmpty) _infoChip(Icons.language, libro.idiomaNombre),
                  ]),
                  if (libro.categoriaNombre.isNotEmpty) ...[const SizedBox(height: 8), _infoChip(Icons.category, libro.categoriaNombre)],
                  const SizedBox(height: 16),
                  Text('\$${libro.precio.toStringAsFixed(2)} MXN', style: const TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.bold, color: Constantes.vinoPrimary)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Icon(noStock ? Icons.cancel : Icons.check_circle, size: 18, color: noStock ? Colors.red : Colors.green),
                    const SizedBox(width: 6),
                    Text(noStock ? 'Agotado' : 'En stock (${libro.stock} disponibles)', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: noStock ? Colors.red : Colors.green, fontWeight: FontWeight.w500)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    ...List.generate(5, (i) => Icon(i < libro.calificacion.floor() ? Icons.star : (i < libro.calificacion ? Icons.star_half : Icons.star_border), size: 22, color: Colors.amber)),
                    const SizedBox(width: 8),
                    Text('${libro.calificacion.toStringAsFixed(1)} (${libro.totalResenas} reseñas)', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Constantes.textDark)),
                  ]),
                  const SizedBox(height: 20),
                  if (libro.descripcion.isNotEmpty) ...[
                    const Text('Descripción', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold, color: Constantes.textDark)),
                    const SizedBox(height: 8),
                    Text(libro.descripcion, style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Constantes.textDark, height: 1.5)),
                    const SizedBox(height: 24),
                  ],
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton.icon(
                      onPressed: noStock ? null : () {
                        context.read<CarritoProvider>().agregarItem(libro);
                        setState(() => _agregado = true);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${libro.titulo} agregado al carrito'), backgroundColor: Colors.green[700], behavior: SnackBarBehavior.floating));
                      },
                      icon: const Icon(Icons.shopping_cart_outlined),
                      label: Text(noStock ? 'Agotado' : 'Agregar al carrito'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: noStock ? Colors.grey : Constantes.vinoPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  if (_agregado) ...[
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, height: 44, child: OutlinedButton.icon(
                      onPressed: () => context.go('/carrito'),
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Ir al carrito'),
                      style: OutlinedButton.styleFrom(foregroundColor: Constantes.vinoSoft, side: const BorderSide(color: Constantes.vinoSoft), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    )),
                  ],
                  const SizedBox(height: 28),
                  // Sección de reseñas
                  const Text('Reseñas', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold, color: Constantes.textDark)),
                  const SizedBox(height: 12),
                  // Stream de reseñas
                  StreamBuilder<QuerySnapshot>(
                    stream: _resenasRef.orderBy('createdAt', descending: true).snapshots(),
                    builder: (_, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
                      }
                      final docs = snap.data?.docs ?? [];
                      final resenas = docs.map((d) => ResenaModelo.fromMap(d.data() as Map<String, dynamic>)).toList();

                      // Check if current user already reviewed
                      final miResena = userId != null ? resenas.where((r) => r.usuarioId == userId).firstOrNull : null;
                      final resenasOtros = userId != null ? resenas.where((r) => r.usuarioId != userId).toList() : resenas;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // My review (if exists)
                          if (miResena != null) ...[
                            const Text('Tu reseña', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Constantes.vinoSoft)),
                            const SizedBox(height: 6),
                            _buildResenaCard(miResena),
                            const SizedBox(height: 12),
                          ],
                          // Review form (if no review yet)
                          if (miResena == null && userId != null) ...[
                            _buildFormularioResena(),
                            const SizedBox(height: 12),
                          ],
                          // Other reviews
                          if (resenasOtros.isEmpty && miResena == null)
                            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('No hay reseñas aún. ¡Sé el primero en comentar!', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Constantes.textDark))))
                          else if (resenasOtros.isEmpty && miResena != null)
                            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: Text('No hay más reseñas', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Constantes.textDark))))
                          else
                            ...resenasOtros.map((r) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _buildResenaCard(r))),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioResena() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Constantes.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: Constantes.vinoSoft.withAlpha(60))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Califica este libro', style: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: Constantes.textDark)),
          const SizedBox(height: 8),
          Row(children: List.generate(5, (i) {
            return IconButton(
              icon: Icon(i < _estrellas ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
              onPressed: () => setState(() => _estrellas = i + 1),
            );
          })),
          const SizedBox(height: 8),
          TextField(
            controller: _comentarioCtrl,
            decoration: const InputDecoration(
              labelText: 'Tu comentario',
              hintText: 'Escribe tu opinión (mín. 10 caracteres)',
            ),
            maxLines: 3,
            maxLength: 500,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_estrellas == 0 || _comentarioCtrl.text.trim().length < 10) ? null : _publicarResena,
              style: ElevatedButton.styleFrom(backgroundColor: Constantes.vinoPrimary, foregroundColor: Colors.white),
              child: const Text('Publicar reseña', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: Constantes.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: Constantes.vinoSoft.withAlpha(100))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: Constantes.vinoSoft),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: Constantes.textDark)),
      ]),
    );
  }

  Widget _buildResenaCard(ResenaModelo resena) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Constantes.cream, borderRadius: BorderRadius.circular(12), border: Border.all(color: Constantes.vinoSoft.withAlpha(60))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(radius: 16, backgroundColor: Constantes.vinoSoft, child: Text(
            resena.usuarioNombre.isNotEmpty ? resena.usuarioNombre[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          )),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(resena.usuarioNombre, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Constantes.textDark)),
            Row(children: List.generate(5, (i) => Icon(i < resena.calificacion.floor() ? Icons.star : Icons.star_border, size: 14, color: Colors.amber))),
          ])),
        ]),
        if (resena.comentario.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(resena.comentario, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Constantes.textDark, height: 1.4)),
        ],
      ]),
    );
  }
}
