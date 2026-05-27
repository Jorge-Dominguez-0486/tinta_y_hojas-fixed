import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/libro_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/autor_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/categoria_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/editorial_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/idioma_modelo.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/componentes/dialogo_confirmacion.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class AdminLibrosVista extends StatefulWidget {
  const AdminLibrosVista({super.key});

  @override
  State<AdminLibrosVista> createState() => _AdminLibrosVistaState();
}

class _AdminLibrosVistaState extends State<AdminLibrosVista> {
  List<LibroModelo> _libros = [];
  List<LibroModelo> _librosFiltrados = [];
  bool _cargando = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarLibros();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarLibros() async {
    setState(() => _cargando = true);
    final libros = await context.read<AdminProvider>().obtenerLibros();
    setState(() {
      _libros = libros;
      _librosFiltrados = libros;
      _cargando = false;
    });
  }

  void _filtrar(String query) {
    setState(() {
      _librosFiltrados = _libros
          .where((l) => l.titulo.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _eliminarLibro(LibroModelo libro) async {
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar libro',
      mensaje: '¿Eliminar "${libro.titulo}" permanentemente?',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (confirmado == true && mounted) {
      await context.read<AdminProvider>().eliminarLibro(libro.id);
      await _cargarLibros();
    }
  }

  void _mostrarFormulario({LibroModelo? libro}) {
    final admin = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _FormularioLibro(
        libro: libro,
        admin: admin,
        onGuardar: () {
          Navigator.of(sheetCtx).pop();
          _cargarLibros();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formato = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Gestión de Libros')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constantes.vinoPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Cargando(
              pantallaCompleta: false,
              mensaje: 'Cargando libros...',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por título...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Constantes.vinoSoft,
                      ),
                      filled: true,
                      fillColor: Constantes.cream,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: _filtrar,
                  ),
                ),
                Expanded(
                  child: _librosFiltrados.isEmpty
                      ? const Center(child: Text('No hay libros registrados'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _librosFiltrados.length,
                          itemBuilder: (_, i) {
                            final l = _librosFiltrados[i];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Constantes.cream,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Constantes.vinoSoft.withAlpha(60),
                                ),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: l.portadaUrl.isNotEmpty
                                      ? Image.network(
                                          l.portadaUrl,
                                          width: 40,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(Icons.book, size: 28),
                                        )
                                      : const Icon(
                                          Icons.book,
                                          size: 28,
                                          color: Constantes.vinoSoft,
                                        ),
                                ),
                                title: Text(
                                  l.titulo,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  '${formato.format(l.precio)} MXN • Stock: ${l.stock}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Constantes.vinoPrimary,
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          _mostrarFormulario(libro: l),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      onPressed: () => _eliminarLibro(l),
                                    ),
                                  ],
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
}

class _FormularioLibro extends StatefulWidget {
  final LibroModelo? libro;
  final AdminProvider admin;
  final VoidCallback onGuardar;

  const _FormularioLibro({
    this.libro,
    required this.admin,
    required this.onGuardar,
  });

  @override
  State<_FormularioLibro> createState() => _FormularioLibroState();
}

class _FormularioLibroState extends State<_FormularioLibro> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  Uint8List? _imagenSeleccionada;
  File? _imagenSeleccionadaFile; // solo para plataformas no-web
  final _imagenUrlCtrl = TextEditingController();
  bool _destacado = false;
  bool _guardando = false;

  List<AutorModelo> _autores = [];
  List<CategoriaModelo> _categorias = [];
  List<EditorialModelo> _editoriales = [];
  List<IdiomaModelo> _idiomas = [];

  String? _autorId;
  String? _categoriaId;
  String? _editorialId;
  String? _idiomaId;

  @override
  void initState() {
    super.initState();
    _cargarSelectores();
    if (widget.libro != null) {
      final l = widget.libro!;
      _tituloCtrl.text = l.titulo;
      _descripcionCtrl.text = l.descripcion;
      _precioCtrl.text = l.precio.toStringAsFixed(2);
      _stockCtrl.text = l.stock.toString();
      _destacado = l.destacado;
      _autorId = l.autorId;
      _categoriaId = l.categoriaId;
      _editorialId = l.editorialId;
      _idiomaId = l.idiomaId;
    }
  }

  Future<void> _cargarSelectores() async {
    final autores = await widget.admin.obtenerAutores();
    final categorias = await widget.admin.obtenerCategorias();
    final editoriales = await widget.admin.obtenerEditoriales();
    final idiomas = await widget.admin.obtenerIdiomas();
    if (mounted) {
      setState(() {
        _autores = autores;
        _categorias = categorias;
        _editoriales = editoriales;
        _idiomas = idiomas;
      });
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _imagenUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        _imagenSeleccionada = bytes;
        if (!kIsWeb) _imagenSeleccionadaFile = File(xFile.path);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    final nombreAutor =
        _autores.where((a) => a.id == _autorId).firstOrNull?.nombre ?? '';
    final nombreCategoria =
        _categorias.where((c) => c.id == _categoriaId).firstOrNull?.nombre ??
        '';
    final nombreEditorial =
        _editoriales.where((e) => e.id == _editorialId).firstOrNull?.nombre ??
        '';
    final nombreIdioma =
        _idiomas.where((i) => i.id == _idiomaId).firstOrNull?.nombre ?? '';

    final imagenUrl = _imagenUrlCtrl.text.trim();
    bool ok;
    if (widget.libro == null) {
      final libro = LibroModelo(
        id: '',
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        autorId: _autorId ?? '',
        autorNombre: nombreAutor,
        categoriaId: _categoriaId ?? '',
        categoriaNombre: nombreCategoria,
        editorialId: _editorialId ?? '',
        editorialNombre: nombreEditorial,
        idiomaId: _idiomaId ?? '',
        idiomaNombre: nombreIdioma,
        precio: double.tryParse(_precioCtrl.text) ?? 0,
        stock: int.tryParse(_stockCtrl.text) ?? 0,
        portadaUrl: '',
        destacado: _destacado,
        createdAt: DateTime.now(),
      );
      ok = await widget.admin.agregarLibro(libro, kIsWeb ? null : _imagenSeleccionadaFile, imagenUrl: imagenUrl, imageBytes: _imagenSeleccionada);
    } else {
      final datos = <String, dynamic>{
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'autorId': _autorId,
        'autorNombre': nombreAutor,
        'categoriaId': _categoriaId,
        'categoriaNombre': nombreCategoria,
        'editorialId': _editorialId,
        'editorialNombre': nombreEditorial,
        'idiomaId': _idiomaId,
        'idiomaNombre': nombreIdioma,
        'precio': double.tryParse(_precioCtrl.text) ?? 0,
        'stock': int.tryParse(_stockCtrl.text) ?? 0,
        'destacado': _destacado,
      };
      ok = await widget.admin.editarLibro(
        widget.libro!.id,
        datos,
        kIsWeb ? null : _imagenSeleccionadaFile,
        imagenUrl: imagenUrl,
        imageBytes: _imagenSeleccionada,
      );
    }

    if (mounted) {
      if (ok) {
        widget.onGuardar();
      } else {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.admin.mensajeError ?? 'Error al guardar'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.libro != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esEdicion ? 'Editar Libro' : 'Nuevo Libro',
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constantes.textDark,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Constantes.cream,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Constantes.vinoSoft.withAlpha(128),
                    ),
                  ),
                  child: _imagenSeleccionada != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _imagenSeleccionada!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : widget.libro?.portadaUrl.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.libro!.portadaUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => _placeholderImagen(),
                          ),
                        )
                      : _placeholderImagen(),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imagenUrlCtrl,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen (opcional)',
                  hintText: 'https://ejemplo.com/imagen.jpg',
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precioCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        prefixText: '\$ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      decoration: const InputDecoration(labelText: 'Stock'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _autorId,
                decoration: const InputDecoration(labelText: 'Autor'),
                items: _autores
                    .map(
                      (a) =>
                          DropdownMenuItem(value: a.id, child: Text(a.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _autorId = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoriaId,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: _categorias
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _categoriaId = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _editorialId,
                      decoration: const InputDecoration(labelText: 'Editorial'),
                      items: _editoriales
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.id,
                              child: Text(e.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _editorialId = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _idiomaId,
                      decoration: const InputDecoration(labelText: 'Idioma'),
                      items: _idiomas
                          .map(
                            (i) => DropdownMenuItem(
                              value: i.id,
                              child: Text(i.nombre),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _idiomaId = v),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text(
                  'Destacado',
                  style: TextStyle(fontFamily: 'Inter'),
                ),
                value: _destacado,
                activeThumbColor: Constantes.vinoPrimary,
                onChanged: (v) => setState(() => _destacado = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(esEdicion ? 'Guardar cambios' : 'Agregar libro'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImagen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 40, color: Constantes.vinoSoft),
          SizedBox(height: 4),
          Text(
            'Tocar para seleccionar imagen',
            style: TextStyle(fontSize: 12, color: Constantes.vinoSoft),
          ),
        ],
      ),
    );
  }
}
