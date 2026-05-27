import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/libros/proveedores/libro_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/carrito_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/tarjeta_libro.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';
import 'package:tinta_y_hojas/compartido/componentes/estado_vacio.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class HomeVista extends StatefulWidget {
  const HomeVista({super.key});

  @override
  State<HomeVista> createState() => _HomeVistaState();
}

class _HomeVistaState extends State<HomeVista> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final librosProv = context.watch<LibroProvider>();
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      backgroundColor: Constantes.beige,
      appBar: AppBar(
        title: const Text(
          '\u{1F4DA} Tinta & Hojas',
          style: TextStyle(fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          if (auth.esAdmin)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () => context.go('/admin'),
            ),
          Badge(
            isLabelVisible: carrito.cantidadItems > 0,
            label: Text(
              '${carrito.cantidadItems}',
              style: const TextStyle(fontSize: 10),
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () => context.go('/carrito'),
            ),
          ),
        ],
      ),
      drawer: const DrawerPrincipal(),
      body: RefreshIndicator(
        onRefresh: () async => context.read<LibroProvider>().cargarLibros(),
        child: librosProv.cargando && librosProv.libros.isEmpty
            ? ListView(
                children: const [
                  _ShimmerItem(),
                  _ShimmerItem(),
                  _ShimmerItem(),
                  _ShimmerItem(),
                ],
              )
            : librosProv.libros.isEmpty && !librosProv.cargando
            ? ListView(
                children: const [
                  SizedBox(height: 80),
                  EstadoVacio(
                    icono: Icons.menu_book_outlined,
                    titulo: 'No hay libros disponibles',
                    subtitulo: 'Pronto agregaremos nuevos títulos',
                  ),
                ],
              )
            : CustomScrollView(
                slivers: [
                  _buildBannerSliver(),
                  _buildSearchSliver(librosProv),
                  _buildCategoriasSliver(librosProv),
                  if (librosProv.librosDestacados.isNotEmpty)
                    _buildDestacadosSliver(librosProv, carrito),
                  _buildTodosLosLibrosSliver(librosProv, carrito),
                ],
              ),
      ),
    );
  }

  Widget _buildBannerSliver() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        height: 120,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Constantes.vinoDark, Constantes.vinoSoft],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Constantes.vinoDark.withAlpha(80),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Círculos decorativos de fondo
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(18),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: -30,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(12),
                ),
              ),
            ),
            // Ícono decorativo
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 56,
                  color: Colors.white.withAlpha(45),
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 90, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descubre nuevas historias',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 30,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Constantes.vinoDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Ver catálogo',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSliver(LibroProvider librosProv) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar libros...',
            prefixIcon: const Icon(Icons.search, color: Constantes.vinoSoft),
            filled: true,
            fillColor: Constantes.cream,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onChanged: (value) => librosProv.buscar(value),
        ),
      ),
    );
  }

  Widget _buildCategoriasSliver(LibroProvider librosProv) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'Géneros',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: librosProv.categorias.length,
              itemBuilder: (_, index) {
                final cat = librosProv.categorias[index];
                final sel = librosProv.categoriaSeleccionada == cat.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(cat.nombre),
                    selected: sel,
                    onSelected: (_) => librosProv.filtrarPorCategoria(cat.id),
                    backgroundColor: Constantes.beige,
                    selectedColor: Constantes.vinoPrimary,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : Constantes.textDark,
                      fontSize: 13,
                    ),
                    side: BorderSide(
                      color: sel ? Constantes.vinoPrimary : Constantes.vinoSoft,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestacadosSliver(
    LibroProvider librosProv,
    CarritoProvider carrito,
  ) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Libros Destacados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: librosProv.librosDestacados.length,
              itemBuilder: (_, index) {
                final libro = librosProv.librosDestacados[index];
                return SizedBox(
                  width: 160,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: TarjetaLibro(
                      libro: libro,
                      onTap: () => context.go('/libro/${libro.id}'),
                      onAgregarCarrito: () {
                        carrito.agregarItem(libro);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${libro.titulo} agregado al carrito',
                            ),
                            backgroundColor: Colors.green[700],
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodosLosLibrosSliver(
    LibroProvider librosProv,
    CarritoProvider carrito,
  ) {
    final libros = librosProv.libros;
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Todos los libros',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Playfair Display',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (libros.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No hay libros disponibles')),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: libros.length,
                itemBuilder: (_, index) {
                  final libro = libros[index];
                  return TarjetaLibro(
                    libro: libro,
                    onTap: () => context.go('/libro/${libro.id}'),
                    onAgregarCarrito: () {
                      carrito.agregarItem(libro);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${libro.titulo} agregado al carrito'),
                          backgroundColor: Colors.green[700],
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ShimmerItem extends StatelessWidget {
  const _ShimmerItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
