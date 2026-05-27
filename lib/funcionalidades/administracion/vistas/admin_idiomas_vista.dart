import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/idioma_modelo.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/componentes/dialogo_confirmacion.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class AdminIdiomasVista extends StatefulWidget {
  const AdminIdiomasVista({super.key});

  @override
  State<AdminIdiomasVista> createState() => _AdminIdiomasVistaState();
}

class _AdminIdiomasVistaState extends State<AdminIdiomasVista> {
  List<IdiomaModelo> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final items = await context.read<AdminProvider>().obtenerIdiomas();
    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  Future<void> _eliminar(IdiomaModelo item) async {
    final ok = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar idioma',
      mensaje: '¿Eliminar "${item.nombre}"?',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok == true && mounted) {
      await context.read<AdminProvider>().eliminarIdioma(item.id);
      await _cargar();
    }
  }

  void _formulario({IdiomaModelo? item}) {
    final admin = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _FormIdioma(
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
      appBar: AppBar(title: const Text('Idiomas')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constantes.vinoPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _formulario(),
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Cargando(pantallaCompleta: false)
          : _items.isEmpty
          ? const Center(child: Text('No hay idiomas'))
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
                    leading: const CircleAvatar(
                      backgroundColor: Constantes.vinoSoft,
                      child: Icon(Icons.language, color: Colors.white),
                    ),
                    title: Text(
                      item.nombre,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      item.codigo.isNotEmpty ? 'Código: ${item.codigo}' : '',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 11),
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

class _FormIdioma extends StatefulWidget {
  final IdiomaModelo? item;
  final AdminProvider admin;
  final VoidCallback onGuardar;
  const _FormIdioma({this.item, required this.admin, required this.onGuardar});

  @override
  State<_FormIdioma> createState() => _FormIdiomaState();
}

class _FormIdiomaState extends State<_FormIdioma> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _codigoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nombreCtrl.text = widget.item!.nombre;
      _codigoCtrl.text = widget.item!.codigo;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.item == null) {
      await widget.admin.agregarIdioma(
        IdiomaModelo(
          id: '',
          nombre: _nombreCtrl.text.trim(),
          codigo: _codigoCtrl.text.trim(),
        ),
      );
    } else {
      await widget.admin.editarIdioma(widget.item!.id, {
        'nombre': _nombreCtrl.text.trim(),
        'codigo': _codigoCtrl.text.trim(),
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
              widget.item != null ? 'Editar Idioma' : 'Nuevo Idioma',
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
              controller: _codigoCtrl,
              decoration: const InputDecoration(
                labelText: 'Código',
                hintText: 'Ej: es, en, fr',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
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
