import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/usuario_modelo.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/compartido/componentes/dialogo_confirmacion.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class AdminUsuariosVista extends StatefulWidget {
  const AdminUsuariosVista({super.key});

  @override
  State<AdminUsuariosVista> createState() => _AdminUsuariosVistaState();
}

class _AdminUsuariosVistaState extends State<AdminUsuariosVista> {
  List<UsuarioModelo> _usuarios = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _cargando = true);
    final usuarios = await context.read<AdminProvider>().obtenerUsuarios();
    setState(() {
      _usuarios = usuarios;
      _cargando = false;
    });
  }

  Future<void> _eliminarUsuario(UsuarioModelo usuario) async {
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Eliminar usuario',
      mensaje: '¿Eliminar a "${usuario.nombre}" permanentemente?',
      textoConfirmar: 'Eliminar',
      peligroso: true,
    );
    if (confirmado == true && mounted) {
      await context.read<AdminProvider>().eliminarUsuario(usuario.id);
      await _cargarUsuarios();
    }
  }

  Future<void> _cambiarRol(UsuarioModelo usuario) async {
    final nuevoRol = usuario.rol == 'admin' ? 'cliente' : 'admin';
    final esAdmin = nuevoRol == 'admin';
    final confirmado = await DialogoConfirmacion.mostrar(
      context,
      titulo: 'Cambiar rol',
      mensaje: esAdmin
          ? '¿Deseas hacer a ${usuario.nombre} administrador?'
          : '¿Deseas quitarle permisos de administrador a ${usuario.nombre}?',
      textoConfirmar: esAdmin ? 'Hacer admin' : 'Hacer cliente',
    );
    if (confirmado == true && mounted) {
      await context.read<AdminProvider>().cambiarRol(usuario.id, nuevoRol);
      await _cargarUsuarios();
    }
  }

  void _mostrarFormulario({UsuarioModelo? usuario}) {
    final admin = context.read<AdminProvider>();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _FormularioUsuario(
        usuario: usuario,
        admin: admin,
        onGuardar: () {
          Navigator.of(sheetCtx).pop();
          _cargarUsuarios();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Gestión de Usuarios')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Constantes.vinoPrimary,
        foregroundColor: Colors.white,
        onPressed: () => _mostrarFormulario(),
        child: const Icon(Icons.person_add),
      ),
      body: _cargando
          ? const Cargando(
              pantallaCompleta: false,
              mensaje: 'Cargando usuarios...',
            )
          : _usuarios.isEmpty
          ? const Center(child: Text('No hay usuarios registrados'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _usuarios.length,
              itemBuilder: (_, i) {
                final u = _usuarios[i];
                final esAdmin = u.rol == 'admin';
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
                    leading: CircleAvatar(
                      backgroundColor: esAdmin
                          ? Constantes.vinoPrimary
                          : Constantes.vinoSoft.withAlpha(100),
                      child: Text(
                        u.nombre.isNotEmpty ? u.nombre[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: esAdmin ? Colors.white : Constantes.textDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            u.nombre,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: esAdmin
                                ? Colors.green.withAlpha(30)
                                : Colors.grey.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            esAdmin ? 'admin' : 'cliente',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: esAdmin
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      u.correo,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 12),
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
                          onPressed: () => _mostrarFormulario(usuario: u),
                        ),
                        IconButton(
                          icon: Icon(
                            esAdmin
                                ? Icons.person_off
                                : Icons.admin_panel_settings,
                            color: Colors.orange,
                            size: 20,
                          ),
                          onPressed: () => _cambiarRol(u),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () => _eliminarUsuario(u),
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

class _FormularioUsuario extends StatefulWidget {
  final UsuarioModelo? usuario;
  final AdminProvider admin;
  final VoidCallback onGuardar;

  const _FormularioUsuario({
    this.usuario,
    required this.admin,
    required this.onGuardar,
  });

  @override
  State<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<_FormularioUsuario> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _contrasenaCtrl = TextEditingController();
  bool _esAdmin = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    if (widget.usuario != null) {
      _nombreCtrl.text = widget.usuario!.nombre;
      _correoCtrl.text = widget.usuario!.correo;
      _telefonoCtrl.text = widget.usuario!.telefono;
      _esAdmin = widget.usuario!.esAdmin;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _contrasenaCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    if (widget.usuario == null) {
      final usuario = UsuarioModelo(
        id: '',
        nombre: _nombreCtrl.text.trim(),
        correo: _correoCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        rol: _esAdmin ? 'admin' : 'cliente',
        createdAt: DateTime.now(),
      );
      await widget.admin.agregarUsuario(usuario, _contrasenaCtrl.text);
    } else {
      await widget.admin.editarUsuario(widget.usuario!.id, {
        'nombre': _nombreCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
      });
    }

    if (mounted) widget.onGuardar();
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.usuario != null;
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
                esEdicion ? 'Editar Usuario' : 'Nuevo Usuario',
                style: const TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Constantes.textDark,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !esEdicion,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Campo requerido';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
              if (!esEdicion) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _contrasenaCtrl,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Campo requerido';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text(
                    'Rol administrador',
                    style: TextStyle(fontFamily: 'Inter'),
                  ),
                  value: _esAdmin,
                  activeThumbColor: Constantes.vinoPrimary,
                  onChanged: (v) => setState(() => _esAdmin = v),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
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
                      : Text(esEdicion ? 'Guardar cambios' : 'Crear usuario'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
