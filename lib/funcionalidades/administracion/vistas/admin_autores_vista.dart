import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/autor_modelo.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/componentes/dialogo_confirmacion.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class AdminAutoresVista extends StatefulWidget {
  const AdminAutoresVista({super.key});

  @override
  State<AdminAutoresVista> createState() => _AdminAutoresVistaState();
}

class _AdminAutoresVistaState extends State<AdminAutoresVista> {
  List<AutorModelo> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final items = await context.read<AdminProvider>().obtenerAutores();
    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  Future<void> _eliminar(AutorModelo item) async {
    final ok = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar autor',
      mensaje: '¿Eliminar a "${item.nombre}"?',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok == true && mounted) {
      await context.read<AdminProvider>().eliminarAutor(item.id);
      await _cargar();
    }
  }

  void _formulario({AutorModelo? item}) {
    final admin = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _FormAutor(
        item: item,
        admin: admin,
        onGuardar: () {
          Navigator.of(sheetCtx).pop();
          _cargar();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Autores')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constantes.vinoPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _formulario(),
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Cargando(pantallaCompleta: false)
          : _items.isEmpty
          ? const Center(child: Text('No hay autores'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (_, i) {
                final item = _items[i];
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
                      borderRadius: BorderRadius.circular(24),
                      child: item.fotoUrl.isNotEmpty
                          ? Image.network(
                              item.fotoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _avatar(item.nombre),
                            )
                          : _avatar(item.nombre),
                    ),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: item.biografia.isNotEmpty
                        ? Text(
                            item.biografia,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Constantes.vinoPrimary,
                            size: 20,
                          ),
                          onPressed: () => _formulario(item: item),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _eliminar(item),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _avatar(String nombre) {
    return CircleAvatar(
      backgroundColor: Constantes.vinoSoft,
      child: Text(
        nombre.isNotEmpty ? nombre[0].toUpperCase() : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FormAutor extends StatefulWidget {
  final AutorModelo? item;
  final AdminProvider admin;
  final VoidCallback onGuardar;
  const _FormAutor({this.item, required this.admin, required this.onGuardar});

  @override
  State<_FormAutor> createState() => _FormAutorState();
}

class _FormAutorState extends State<_FormAutor> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _biografiaCtrl = TextEditingController();
  Uint8List? _imagen;
  File? _imagenFile; // solo para plataformas no-web
  final _imagenUrlCtrl = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nombreCtrl.text = widget.item!.nombre;
      _biografiaCtrl.text = widget.item!.biografia;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _biografiaCtrl.dispose();
    _imagenUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final x = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (x != null) {
      final bytes = await x.readAsBytes();
      setState(() {
        _imagen = bytes;
        if (!kIsWeb) _imagenFile = File(x.path);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final imagenUrl = _imagenUrlCtrl.text.trim();
    bool ok;
    if (widget.item == null) {
      ok = await widget.admin.agregarAutor(
        AutorModelo(
          id: '',
          nombre: _nombreCtrl.text.trim(),
          biografia: _biografiaCtrl.text.trim(),
        ),
        kIsWeb ? null : _imagenFile,
        imagenUrl: imagenUrl,
        imageBytes: _imagen,
      );
    } else {
      ok = await widget.admin.editarAutor(widget.item!.id, {
        'nombre': _nombreCtrl.text.trim(),
        'biografia': _biografiaCtrl.text.trim(),
      }, kIsWeb ? null : _imagenFile, imagenUrl: imagenUrl, imageBytes: _imagen);
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.item != null ? 'Editar Autor' : 'Nuevo Autor',
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constantes.textDark,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _seleccionarImagen,
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Constantes.cream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Constantes.vinoSoft.withAlpha(128)),
                ),
                child: _imagen != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          _imagen!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : widget.item?.fotoUrl.isNotEmpty == true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.item!.fotoUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => _placeholder(),
                        ),
                      )
                    : _placeholder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _imagenUrlCtrl,
              decoration: const InputDecoration(
                labelText: 'URL de foto (opcional)',
                hintText: 'https://ejemplo.com/foto.jpg',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _biografiaCtrl,
              decoration: const InputDecoration(labelText: 'Biografía'),
              maxLines: 3,
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
                    : Text(
                        widget.item != null ? 'Guardar cambios' : 'Agregar',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 32, color: Constantes.vinoSoft),
          Text(
            'Foto del autor',
            style: TextStyle(fontSize: 11, color: Constantes.vinoSoft),
          ),
        ],
      ),
    );
  }
}
