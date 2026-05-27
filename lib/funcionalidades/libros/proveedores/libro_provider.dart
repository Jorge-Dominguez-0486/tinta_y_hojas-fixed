import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinta_y_hojas/compartido/modelos/libro_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/categoria_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/autor_modelo.dart';

class LibroProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _librosSubscription;

  List<LibroModelo> _libros = [];
  List<LibroModelo> _librosFiltrados = [];
  List<CategoriaModelo> _categorias = [];
  List<AutorModelo> _autores = [];
  bool _cargando = false;
  String? _mensajeError;
  String _busqueda = '';
  String _categoriaSeleccionada = '';

  List<LibroModelo> get libros => _busqueda.isEmpty && _categoriaSeleccionada.isEmpty
      ? _libros
      : _librosFiltrados;
  List<LibroModelo> get librosDestacados =>
      _libros.where((l) => l.destacado).toList();
  List<CategoriaModelo> get categorias => _categorias;
  List<AutorModelo> get autores => _autores;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;
  String get busqueda => _busqueda;
  String get categoriaSeleccionada => _categoriaSeleccionada;

  LibroProvider() {
    cargarLibros();
    cargarCategorias();
    cargarAutores();
  }

  @override
  void dispose() {
    _librosSubscription?.cancel();
    super.dispose();
  }

  void cargarLibros() {
    _cargando = true;
    notifyListeners();

    _librosSubscription = _firestore
        .collection('libros')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _libros = snapshot.docs
          .map((doc) => LibroModelo.fromMap(doc.data()))
          .toList();
      _aplicarFiltros();
      _cargando = false;
      _mensajeError = null;
      notifyListeners();
    }, onError: (e) {
      _cargando = false;
      _mensajeError = 'Error al cargar libros: $e';
      notifyListeners();
    });
  }

  Future<void> cargarCategorias() async {
    try {
      final snapshot = await _firestore.collection('categorias').get();
      _categorias = snapshot.docs
          .map((doc) => CategoriaModelo.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      // Silently fail for secondary data
    }
  }

  Future<void> cargarAutores() async {
    try {
      final snapshot = await _firestore.collection('autores').get();
      _autores = snapshot.docs
          .map((doc) => AutorModelo.fromMap(doc.data()))
          .toList();
      notifyListeners();
    } catch (e) {
      // Silently fail for secondary data
    }
  }

  void _aplicarFiltros() {
    var resultado = List<LibroModelo>.from(_libros);

    if (_busqueda.isNotEmpty) {
      final query = _busqueda.toLowerCase();
      resultado = resultado
          .where((l) =>
              l.titulo.toLowerCase().contains(query) ||
              l.autorNombre.toLowerCase().contains(query))
          .toList();
    }

    if (_categoriaSeleccionada.isNotEmpty) {
      resultado = resultado
          .where((l) => l.categoriaId == _categoriaSeleccionada)
          .toList();
    }

    _librosFiltrados = resultado;
  }

  void buscar(String texto) {
    _busqueda = texto;
    _aplicarFiltros();
    notifyListeners();
  }

  void filtrarPorCategoria(String categoriaId) {
    if (_categoriaSeleccionada == categoriaId) {
      _categoriaSeleccionada = '';
    } else {
      _categoriaSeleccionada = categoriaId;
    }
    _aplicarFiltros();
    notifyListeners();
  }

  void limpiarFiltros() {
    _busqueda = '';
    _categoriaSeleccionada = '';
    _librosFiltrados = List.from(_libros);
    notifyListeners();
  }

  Future<LibroModelo?> cargarLibrosPorId(String id) async {
    try {
      final doc = await _firestore.collection('libros').doc(id).get();
      if (doc.exists) {
        return LibroModelo.fromMap(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  LibroModelo? obtenerPorId(String id) {
    try {
      return _libros.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> agregarLibro(LibroModelo libro) async {
    try {
      await _firestore.collection('libros').doc(libro.id).set(libro.toMap());
    } catch (e) {
      _mensajeError = 'Error al agregar libro: $e';
      notifyListeners();
    }
  }

  Future<void> actualizarLibro(LibroModelo libro) async {
    try {
      await _firestore.collection('libros').doc(libro.id).update(libro.toMap());
    } catch (e) {
      _mensajeError = 'Error al actualizar libro: $e';
      notifyListeners();
    }
  }

  Future<void> eliminarLibro(String id) async {
    try {
      await _firestore.collection('libros').doc(id).delete();
    } catch (e) {
      _mensajeError = 'Error al eliminar libro: $e';
      notifyListeners();
    }
  }
}
