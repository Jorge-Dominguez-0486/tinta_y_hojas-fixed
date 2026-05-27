import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class EditarPerfilVista extends StatefulWidget {
  const EditarPerfilVista({super.key});

  @override
  State<EditarPerfilVista> createState() => _EditarPerfilVistaState();
}

class _EditarPerfilVistaState extends State<EditarPerfilVista> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  Uint8List? _imagen;
  File? _imagenFile; // solo para plataformas no-web
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().usuarioActual;
    if (user != null) {
      _nombreCtrl.text = user.nombre;
      _telefonoCtrl.text = user.telefono;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
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

    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.usuarioActual!.id;
      final datos = <String, dynamic>{
        'nombre': _nombreCtrl.text.trim(),
        'telefono': _telefonoCtrl.text.trim(),
      };

      if (_imagen != null) {
        final ref = FirebaseStorage.instance.ref().child('perfiles/$userId');
        if (kIsWeb) {
          await ref.putData(_imagen!);
        } else {
          await ref.putFile(_imagenFile!);
        }
        final url = await ref.getDownloadURL();
        datos['fotoUrl'] = url;
      }

      await FirebaseFirestore.instance.collection('usuarios').doc(userId).update(datos);

      if (mounted) {
        await auth.cargarUsuario(userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().usuarioActual;

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Constantes.vinoSoft,
                      backgroundImage: _imagen != null
                          ? MemoryImage(_imagen!)
                          : (user != null && user.fotoUrl.isNotEmpty ? NetworkImage(user.fotoUrl) : null) as ImageProvider?,
                      child: (_imagen == null && (user == null || user.fotoUrl.isEmpty))
                          ? Text(
                              user != null && user.nombre.isNotEmpty ? user.nombre[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: Constantes.vinoPrimary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person)),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _telefonoCtrl,
                decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone)),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _guardando ? null : _guardar,
                  style: ElevatedButton.styleFrom(backgroundColor: Constantes.vinoPrimary, foregroundColor: Colors.white),
                  child: _guardando
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Guardar cambios', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
