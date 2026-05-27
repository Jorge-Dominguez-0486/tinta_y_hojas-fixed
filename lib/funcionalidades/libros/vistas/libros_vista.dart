import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/libros/proveedores/libro_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/tarjeta_libro.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class LibrosVista extends StatefulWidget {
  const LibrosVista({super.key});

  @override
  State<LibrosVista> createState() => _LibrosVistaState();
}

class _LibrosVistaState extends State<LibrosVista> {
  final _busquedaController = TextEditingController();

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DrawerPrincipal(),
      appBar: AppBar(
        title: const Text('Libros'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _busquedaController,
              decoration: InputDecoration(
                hintText: 'Buscar libros...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busquedaController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _busquedaController.clear();
                          context.read<LibroProvider>().buscar('');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => context.read<LibroProvider>().buscar(value),
            ),
          ),
          Expanded(
            child: Consumer<LibroProvider>(
              builder: (_, provider, __) {
                if (provider.cargando) {
                  return const Cargando(pantallaCompleta: false);
                }

                if (provider.libros.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Constantes.vinoSoft.withAlpha(128)),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron libros',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: provider.libros.length,
                  itemBuilder: (_, index) {
                    final libro = provider.libros[index];
                    return TarjetaLibro(
                      libro: libro,
                      onTap: () => context.go('/libro/${libro.id}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
