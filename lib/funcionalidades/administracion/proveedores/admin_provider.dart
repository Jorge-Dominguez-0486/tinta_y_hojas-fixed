import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:tinta_y_hojas/compartido/modelos/libro_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/usuario_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/pedido_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/autor_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/categoria_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/editorial_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/idioma_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/proveedor_modelo.dart';

class AdminProvider extends ChangeNotifier {
  static const String _cloudinaryCloud = 'dtowwgjza';
  static const String _cloudinaryPreset = 'ivettgallegos';
  static const String _cloudinaryUrl = 'https://api.cloudinary.com/v1_1/$_cloudinaryCloud/image/upload';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int _totalLibros = 0;
  int _totalUsuarios = 0;
  int _pedidosPendientes = 0;
  bool _cargando = false;
  String? _mensajeError;

  int get totalLibros => _totalLibros;
  int get totalUsuarios => _totalUsuarios;
  int get pedidosPendientes => _pedidosPendientes;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  Future<void> cargarDashboard() async {
    try {
      _cargando = true;
      notifyListeners();

      final librosCount = await _firestore.collection('libros').count().get();
      _totalLibros = librosCount.count ?? 0;

      final usuariosCount = await _firestore.collection('usuarios').count().get();
      _totalUsuarios = usuariosCount.count ?? 0;

      final pedidosPend = await _firestore
          .collection('pedidos')
          .where('estado', isEqualTo: 'pendiente')
          .count()
          .get();
      _pedidosPendientes = pedidosPend.count ?? 0;

      _mensajeError = null;
    } catch (e) {
      _mensajeError = 'Error al cargar dashboard: $e';
    }
    _cargando = false;
    notifyListeners();
  }

  // --- IMAGE UPLOAD ---

  Future<String> _subirACloudinary(File imagen) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
      request.fields['upload_preset'] = _cloudinaryPreset;
      request.files.add(await http.MultipartFile.fromPath('file', imagen.path));
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body = await streamed.stream.bytesToString();
      final json = jsonDecode(body);
      if (json['secure_url'] != null) return json['secure_url'] as String;
      throw Exception(json['error']?['message'] ?? 'Error al subir imagen a Cloudinary');
    } catch (e) {
      if (e is FormatException || e is http.ClientException) {
        throw Exception('Error de conexión al subir imagen');
      }
      rethrow;
    }
  }

  Future<String> _subirBytesACloudinary(Uint8List bytes) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_cloudinaryUrl));
      request.fields['upload_preset'] = _cloudinaryPreset;
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'upload.jpg',
        ),
      );
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final body = await streamed.stream.bytesToString();
      final json = jsonDecode(body);
      if (json['secure_url'] != null) return json['secure_url'] as String;
      throw Exception(json['error']?['message'] ?? 'Error al subir imagen a Cloudinary');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _subirUrlACloudinary(String url) async {
    try {
      final response = await http
          .post(
            Uri.parse(_cloudinaryUrl),
            body: {'upload_preset': _cloudinaryPreset, 'file': url},
          )
          .timeout(const Duration(seconds: 30));
      final json = jsonDecode(response.body);
      if (json['secure_url'] != null) return json['secure_url'] as String;
      throw Exception(json['error']?['message'] ?? 'Error al subir URL a Cloudinary');
    } catch (e) {
      if (e is FormatException || e is http.ClientException) {
        throw Exception('Error de conexión al subir imagen desde URL');
      }
      rethrow;
    }
  }

  // Returns the URL from bytes (web), file (native), URL string, or empty
  Future<String> _obtenerImagenUrl(File? imagen, String? imagenUrl, {Uint8List? imageBytes}) async {
    if (kIsWeb && imageBytes != null) return _subirBytesACloudinary(imageBytes);
    if (!kIsWeb && imagen != null) return _subirACloudinary(imagen);
    if (imagenUrl != null && imagenUrl.isNotEmpty) return _subirUrlACloudinary(imagenUrl);
    return '';
  }

  // --- LIBROS ---

  Future<bool> agregarLibro(LibroModelo libro, File? imagen, {String? imagenUrl, Uint8List? imageBytes}) async {
    try {
      final url = await _obtenerImagenUrl(imagen, imagenUrl, imageBytes: imageBytes);
      final portadaUrl = url.isNotEmpty ? url : libro.portadaUrl;
      final nuevo = libro.copyWith(id: const Uuid().v4(), portadaUrl: portadaUrl);
      await _firestore.collection('libros').doc(nuevo.id).set(nuevo.toMap());
      return true;
    } catch (e) {
      _mensajeError = 'Error al agregar libro: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarLibro(String id, Map<String, dynamic> datos, File? nuevaImagen, {String? imagenUrl, Uint8List? imageBytes}) async {
    try {
      final url = await _obtenerImagenUrl(nuevaImagen, imagenUrl, imageBytes: imageBytes);
      if (url.isNotEmpty) datos['portadaUrl'] = url;
      await _firestore.collection('libros').doc(id).update(datos);
      return true;
    } catch (e) {
      _mensajeError = 'Error al editar libro: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarLibro(String id) async {
    try {
      await _firestore.collection('libros').doc(id).delete();
      return true;
    } catch (e) {
      _mensajeError = 'Error al eliminar libro: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<LibroModelo>> obtenerLibros() async {
    try {
      final snap = await _firestore.collection('libros').orderBy('titulo').get();
      return snap.docs.map((d) => LibroModelo.fromMap(d.data())).toList();
    } catch (e) {
      _mensajeError = 'Error al obtener libros: $e';
      notifyListeners();
      return [];
    }
  }

  // --- AUTORES ---

  Future<bool> agregarAutor(AutorModelo autor, File? imagen, {String? imagenUrl, Uint8List? imageBytes}) async {
    try {
      final url = await _obtenerImagenUrl(imagen, imagenUrl, imageBytes: imageBytes);
      final fotoUrl = url.isNotEmpty ? url : autor.fotoUrl;
      final nuevo = autor.copyWith(id: const Uuid().v4(), fotoUrl: fotoUrl);
      await _firestore.collection('autores').doc(nuevo.id).set(nuevo.toMap());
      return true;
    } catch (e) {
      _mensajeError = 'Error al agregar autor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarAutor(String id, Map<String, dynamic> datos, File? nuevaImagen, {String? imagenUrl, Uint8List? imageBytes}) async {
    try {
      final url = await _obtenerImagenUrl(nuevaImagen, imagenUrl, imageBytes: imageBytes);
      if (url.isNotEmpty) datos['fotoUrl'] = url;
      await _firestore.collection('autores').doc(id).update(datos);
      return true;
    } catch (e) {
      _mensajeError = 'Error al editar autor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarAutor(String id) async {
    try {
      await _firestore.collection('autores').doc(id).delete();
      return true;
    } catch (e) {
      _mensajeError = 'Error al eliminar autor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<AutorModelo>> obtenerAutores() async {
    try {
      final snap = await _firestore.collection('autores').orderBy('nombre').get();
      return snap.docs.map((d) => AutorModelo.fromMap(d.data())).toList();
    } catch (e) {
      _mensajeError = 'Error al obtener autores: $e';
      notifyListeners();
      return [];
    }
  }

  // --- CATEGORIAS ---

  Future<bool> agregarCategoria(CategoriaModelo categoria) async {
    try {
      final nuevo = categoria.copyWith(id: const Uuid().v4());
      await _firestore.collection('categorias').doc(nuevo.id).set(nuevo.toMap());
      return true;
    } catch (e) {
      _mensajeError = 'Error al agregar categoría: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarCategoria(String id, Map<String, dynamic> datos) async {
    try {
      await _firestore.collection('categorias').doc(id).update(datos);
      return true;
    } catch (e) {
      _mensajeError = 'Error al editar categoría: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarCategoria(String id) async {
    try {
      await _firestore.collection('categorias').doc(id).delete();
      return true;
    } catch (e) {
      _mensajeError = 'Error al eliminar categoría: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<CategoriaModelo>> obtenerCategorias() async {
    try {
      final snap = await _firestore.collection('categorias').orderBy('nombre').get();
      return snap.docs.map((d) => CategoriaModelo.fromMap(d.data())).toList();
    } catch (e) {
      _mensajeError = 'Error al obtener categorías: $e';
      notifyListeners();
      return [];
    }
  }

  // --- EDITORIALES ---

  Future<bool> agregarEditorial(EditorialModelo editorial) async {
    try {
      final nuevo = editorial.copyWith(id: const Uuid().v4());
      await _firestore.collection('editoriales').doc(nuevo.id).set(nuevo.toMap());
      return true;
    } catch (e) {
      _mensajeError = 'Error al agregar editorial: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarEditorial(String id, Map<String, dynamic> datos) async {
    try {
      await _firestore.collection('editoriales').doc(id).update(datos);
      return true;
    } catch (e) {
      _mensajeError = 'Error al editar editorial: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarEditorial(String id) async {
    try {
      await _firestore.collection('editoriales').doc(id).delete();
      return true;
    } catch (e) {
      _mensajeError = 'Error al eliminar editorial: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<EditorialModelo>> obtenerEditoriales() async {
    try {
      final snap = await _firestore.collection('editoriales').orderBy('nombre').get();
      return snap.docs.map((d) => EditorialModelo.fromMap(d.data())).toList();
    } catch (e) {
      _mensajeError = 'Error al obtener editoriales: $e';
      notifyListeners();
      return [];
    }
  }

  // --- IDIOMAS ---

  Future<bool> agregarIdioma(IdiomaModelo idioma) async {
    try {
      final nuevo = idioma.copyWith(id: const Uuid().v4());
      await _firestore.collection('idiomas').doc(nuevo.id).set(nuevo.toMap());
      return true;
    } catch (e) {
      _mensajeError = 'Error al agregar idioma: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarIdioma(String id, Map<String, dynamic> datos) async {
    try {
      await _firestore.collection('idiomas').doc(id).update(datos);
      return true;
    } catch (e) {
      _mensajeError = 'Error al editar idioma: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarIdioma(String id) async {
    try {
      await _firestore.collection('idiomas').doc(id).delete();
      return true;
    } catch (e) {
      _mensajeError = 'Error al eliminar idioma: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<IdiomaModelo>> obtenerIdiomas() async {
    try {
      final snap = await _firestore.collection('idiomas').orderBy('nombre').get();
      return snap.docs.map((d) => IdiomaModelo.fromMap(d.data())).toList();
    } catch (e) {
      _mensajeError = 'Error al obtener idiomas: $e';
      notifyListeners();
      return [];
    }
  }

  // --- PROVEEDORES ---

  Future<bool> agregarProveedor(ProveedorModelo proveedor) async {
    try {
      final nuevo = proveedor.copyWith(id: const Uuid().v4());
      await _firestore.collection('proveedores').doc(nuevo.id).set(nuevo.toMap());
      return true;
    } catch (e) {
      _mensajeError = 'Error al agregar proveedor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarProveedor(String id, Map<String, dynamic> datos) async {
    try {
      await _firestore.collection('proveedores').doc(id).update(datos);
      return true;
    } catch (e) {
      _mensajeError = 'Error al editar proveedor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarProveedor(String id) async {
    try {
      await _firestore.collection('proveedores').doc(id).delete();
      return true;
    } catch (e) {
      _mensajeError = 'Error al eliminar proveedor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<List<ProveedorModelo>> obtenerProveedores() async {
    try {
      final snap = await _firestore.collection('proveedores').orderBy('nombre').get();
      return snap.docs.map((d) => ProveedorModelo.fromMap(d.data())).toList();
    } catch (e) {
      _mensajeError = 'Error al obtener proveedores: $e';
      notifyListeners();
      return [];
    }
  }

  // --- USUARIOS ---

  Future<List<UsuarioModelo>> obtenerUsuarios() async {
    try {
      final snap = await _firestore.collection('usuarios').orderBy('nombre').get();
      return snap.docs.map((d) => UsuarioModelo.fromMap(d.data())).toList();
    } catch (e) {
      _mensajeError = 'Error al obtener usuarios: $e';
      notifyListeners();
      return [];
    }
  }

  Future<bool> agregarUsuario(UsuarioModelo usuario, String contrasena) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: usuario.correo,
        password: contrasena,
      );
      final uid = credential.user!.uid;
      final nuevo = usuario.copyWith(id: uid);
      await _firestore.collection('usuarios').doc(uid).set(nuevo.toMap());
      return true;
    } catch (e) {
      _mensajeError = 'Error al agregar usuario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> editarUsuario(String id, Map<String, dynamic> datos) async {
    try {
      await _firestore.collection('usuarios').doc(id).update(datos);
      return true;
    } catch (e) {
      _mensajeError = 'Error al editar usuario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarUsuario(String id) async {
    try {
      await _firestore.collection('usuarios').doc(id).delete();
      return true;
    } catch (e) {
      _mensajeError = 'Error al eliminar usuario: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> cambiarRol(String userId, String nuevoRol) async {
    try {
      await _firestore.collection('usuarios').doc(userId).update({'rol': nuevoRol});
      return true;
    } catch (e) {
      _mensajeError = 'Error al cambiar rol: $e';
      notifyListeners();
      return false;
    }
  }

  // --- PEDIDOS ---

  Stream<List<PedidoModelo>> pedidosStream() {
    return _firestore
        .collection('pedidos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => PedidoModelo.fromMap(d.data()))
            .toList());
  }

  Future<bool> actualizarEstadoPedido(String pedidoId, String nuevoEstado) async {
    try {
      await _firestore.collection('pedidos').doc(pedidoId).update({
        'estado': nuevoEstado,
      });
      return true;
    } catch (e) {
      _mensajeError = 'Error al actualizar estado: $e';
      notifyListeners();
      return false;
    }
  }
}
