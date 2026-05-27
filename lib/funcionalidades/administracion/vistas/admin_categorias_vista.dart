import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/categoria_modelo.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/componentes/dialogo_confirmacion.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class AdminCategoriasVista extends StatefulWidget {
  const AdminCategoriasVista({super.key});

  @override
  State<AdminCategoriasVista> createState() => _AdminCategoriasVistaState();
}

class _AdminCategoriasVistaState extends State<AdminCategoriasVista> {
  List<CategoriaModelo> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final items = await context.read<AdminProvider>().obtenerCategorias();
    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  Future<void> _eliminar(CategoriaModelo item) async {
    final ok = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar categoría',
      mensaje: '¿Eliminar "${item.nombre}"?',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok == true && mounted) {
      await context.read<AdminProvider>().eliminarCategoria(item.id);
      await _cargar();
    }
  }

  void _formulario({CategoriaModelo? item}) {
    final admin = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _FormCategoria(
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
      appBar: AppBar(title: const Text('Categorías')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constantes.vinoPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _formulario(),
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Cargando(pantallaCompleta: false)
          : _items.isEmpty
          ? const Center(child: Text('No hay categorías'))
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
                    leading: Text(
                      item.icono.isNotEmpty ? item.icono : '📁',
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
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
}

class _FormCategoria extends StatefulWidget {
  final CategoriaModelo? item;
  final AdminProvider admin;
  final VoidCallback onGuardar;
  const _FormCategoria({
    this.item,
    required this.admin,
    required this.onGuardar,
  });

  @override
  State<_FormCategoria> createState() => _FormCategoriaState();
}

class _FormCategoriaState extends State<_FormCategoria> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _iconoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nombreCtrl.text = widget.item!.nombre;
      _iconoCtrl.text = widget.item!.icono;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _iconoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.item == null) {
      await widget.admin.agregarCategoria(
        CategoriaModelo(
          id: '',
          nombre: _nombreCtrl.text.trim(),
          icono: _iconoCtrl.text.trim(),
        ),
      );
    } else {
      await widget.admin.editarCategoria(widget.item!.id, {
        'nombre': _nombreCtrl.text.trim(),
        'icono': _iconoCtrl.text.trim(),
      });
    }
    if (mounted) widget.onGuardar();
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
              widget.item != null ? 'Editar Categoría' : 'Nueva Categoría',
              style: const TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constantes.textDark,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _iconoCtrl,
              decoration: const InputDecoration(
                labelText: 'Emoji / Icono',
                hintText: 'Ej: 📚',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardar,
                child: Text(
                  widget.item != null ? 'Guardar cambios' : 'Agregar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
