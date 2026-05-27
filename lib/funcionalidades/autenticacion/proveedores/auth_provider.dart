import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinta_y_hojas/compartido/modelos/usuario_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/libro_modelo.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _authSubscription;

  UsuarioModelo? usuarioActual;
  bool cargando = true;
  String? errorMensaje;

  final Set<String> _favoritosIds = {};
  bool get tieneFavoritos => _favoritosIds.isNotEmpty;
  int get cantidadFavoritos => _favoritosIds.length;

  bool esFavorito(String libroId) => _favoritosIds.contains(libroId);

  bool get estaAutenticado => usuarioActual != null;
  bool get esAdmin => usuarioActual?.esAdmin ?? false;

  AuthProvider() {
    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await cargarUsuario(user.uid);
        if (usuarioActual != null) {
          await _cargarFavoritos(user.uid);
        }
      } else {
        usuarioActual = null;
        _favoritosIds.clear();
        cargando = false;
        errorMensaje = null;
        notifyListeners();
      }
    });
  }

  Future<void> _cargarFavoritos(String uid) async {
    try {
      final snap = await _firestore
          .collection('favoritos')
          .where('usuarioId', isEqualTo: uid)
          .get();
      _favoritosIds.clear();
      for (final doc in snap.docs) {
        _favoritosIds.add((doc.data()['libroId'] ?? '').toString());
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> agregarFavorito(String libroId, LibroModelo libro) async {
    final userId = usuarioActual?.id;
    if (userId == null) return;
    final docId = '${userId}_$libroId';
    try {
      await _firestore.collection('favoritos').doc(docId).set({
        'usuarioId': userId,
        'libroId': libroId,
        'titulo': libro.titulo,
        'portadaUrl': libro.portadaUrl,
        'precio': libro.precio,
      });
      _favoritosIds.add(libroId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> quitarFavorito(String libroId) async {
    final userId = usuarioActual?.id;
    if (userId == null) return;
    final docId = '${userId}_$libroId';
    try {
      await _firestore.collection('favoritos').doc(docId).delete();
      _favoritosIds.remove(libroId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleFavorito(String libroId, LibroModelo libro) async {
    if (esFavorito(libroId)) {
      await quitarFavorito(libroId);
    } else {
      await agregarFavorito(libroId, libro);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> cargarUsuario(String uid) async {
    try {
      cargando = true;
      errorMensaje = null;
      notifyListeners();

      final doc = await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        usuarioActual = UsuarioModelo.fromMap(doc.data()!);
      } else {
        usuarioActual = null;
      }
      cargando = false;
    } catch (e) {
      cargando = false;
      errorMensaje = 'Error al cargar usuario: $e';
    }
    notifyListeners();
  }

  Future<void> registrar({
    required String nombre,
    required String correo,
    required String contrasena,
    String telefono = '',
  }) async {
    try {
      cargando = true;
      errorMensaje = null;
      notifyListeners();

      final credencial = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );

      final usuario = UsuarioModelo(
        id: credencial.user!.uid,
        nombre: nombre,
        correo: correo,
        telefono: telefono,
        rol: 'cliente',
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('usuarios')
          .doc(credencial.user!.uid)
          .set(usuario.toMap());

      usuarioActual = usuario;
      cargando = false;
    } on FirebaseAuthException catch (e) {
      cargando = false;
      errorMensaje = _traducirError(e.code);
    } catch (e) {
      cargando = false;
      errorMensaje = 'Error de red. Intenta de nuevo.';
    }
    notifyListeners();
  }

  Future<void> iniciarSesion({
    required String correo,
    required String contrasena,
  }) async {
    try {
      cargando = true;
      errorMensaje = null;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
    } on FirebaseAuthException catch (e) {
      cargando = false;
      errorMensaje = _traducirError(e.code);
      notifyListeners();
    } catch (e) {
      cargando = false;
      errorMensaje = 'Error de red. Intenta de nuevo.';
      notifyListeners();
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    usuarioActual = null;
    cargando = false;
    errorMensaje = null;
    notifyListeners();
  }

  Future<void> recuperarPassword(String correo) async {
    try {
      cargando = true;
      errorMensaje = null;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: correo);
      cargando = false;
    } on FirebaseAuthException catch (e) {
      cargando = false;
      errorMensaje = _traducirError(e.code);
    } catch (e) {
      cargando = false;
      errorMensaje = 'Error de red. Intenta de nuevo.';
    }
    notifyListeners();
  }

  void limpiarError() {
    errorMensaje = null;
    notifyListeners();
  }

  String _traducirError(String codigo) {
    switch (codigo) {
      case 'user-not-found':
        return 'No se encontró una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'invalid-email':
        return 'El formato del correo no es válido';
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'network-request-failed':
        return 'Error de conexión. Verifica tu internet';
      case 'operation-not-allowed':
        return 'Operación no permitida';
      case 'expired-action-code':
        return 'El enlace ha expirado';
      case 'invalid-action-code':
        return 'El enlace no es válido';
      default:
        return 'Error de autenticación. Intenta de nuevo.';
    }
  }
}
