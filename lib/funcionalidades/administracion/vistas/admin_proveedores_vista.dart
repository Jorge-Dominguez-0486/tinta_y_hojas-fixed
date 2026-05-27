import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/proveedor_modelo.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/componentes/dialogo_confirmacion.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class AdminProveedoresVista extends StatefulWidget {
  const AdminProveedoresVista({super.key});

  @override
  State<AdminProveedoresVista> createState() => _AdminProveedoresVistaState();
}

class _AdminProveedoresVistaState extends State<AdminProveedoresVista> {
  List<ProveedorModelo> _items = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final items = await context.read<AdminProvider>().obtenerProveedores();
    setState(() {
      _items = items;
      _cargando = false;
    });
  }

  Future<void> _eliminar(ProveedorModelo item) async {
    final ok = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar proveedor',
      mensaje: '¿Eliminar a "${item.nombre}"?',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (ok == true && mounted) {
      await context.read<AdminProvider>().eliminarProveedor(item.id);
      await _cargar();
    }
  }

  void _formulario({ProveedorModelo? item}) {
    final admin = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _FormProveedor(
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
      appBar: AppBar(title: const Text('Proveedores')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constantes.vinoPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _formulario(),
        child: const Icon(Icons.add),
      ),
      body: _cargando
          ? const Cargando(pantallaCompleta: false)
          : _items.isEmpty
          ? const Center(child: Text('No hay proveedores'))
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
                      child: Icon(Icons.local_shipping, color: Colors.white),
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
                      [
                        item.telefono,
                        item.correo,
                      ].where((s) => s.isNotEmpty).join(' • '),
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

class _FormProveedor extends StatefulWidget {
  final ProveedorModelo? item;
  final AdminProvider admin;
  final VoidCallback onGuardar;
  const _FormProveedor({
    this.item,
    required this.admin,
    required this.onGuardar,
  });

  @override
  State<_FormProveedor> createState() => _FormProveedorState();
}

class _FormProveedorState extends State<_FormProveedor> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nombreCtrl.text = widget.item!.nombre;
      _telefonoCtrl.text = widget.item!.telefono;
      _correoCtrl.text = widget.item!.correo;
      _direccionCtrl.text = widget.item!.direccion;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _correoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.item == null) {
      await widget.admin.agregarProveedor(
        ProveedorModelo(
          id: '',
          nombre: _nombreCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          correo: _correoCtrl.text.trim(),
          direccion: _direccionCtrl.text.trim(),
        ),
      );
    } else {
      await widget.admin.editarProveedor(widget.item!.id, {
        'nombre': _nombreCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
        'correo': _correoCtrl.text.trim(),
        'direccion': _direccionCtrl.text.trim(),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item != null ? 'Editar Proveedor' : 'Nuevo Proveedor',
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
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(labelText: 'Dirección'),
                maxLines: 2,
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
      ),
    );
  }
}
