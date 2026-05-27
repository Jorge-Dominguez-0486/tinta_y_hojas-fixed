import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:tinta_y_hojas/compartido/modelos/carrito_item_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/libro_modelo.dart';
import 'package:tinta_y_hojas/compartido/modelos/pedido_modelo.dart';

class CarritoProvider extends ChangeNotifier {
  List<CarritoItemModelo> _items = [];
  bool _cargando = false;
  static const String _storageKey = 'carrito_items';

  List<CarritoItemModelo> get items => List.unmodifiable(_items);
  bool get cargando => _cargando;
  bool get estaVacio => _items.isEmpty;
  int get cantidadItems => _items.fold(0, (sum, item) => sum + item.cantidad);
  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  CarritoProvider() {
    _cargarDesdeStorage();
  }

  Future<void> _cargarDesdeStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> decoded = jsonDecode(data);
        _items = decoded
            .map((e) => CarritoItemModelo.fromMap(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _guardarEnStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_items.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, data);
    } catch (_) {}
  }

  Future<void> agregarItem(LibroModelo libro) async {
    final index = _items.indexWhere((item) => item.libroId == libro.id);
    if (index != -1) {
      _items[index].cantidad++;
    } else {
      _items.add(CarritoItemModelo(
        libroId: libro.id,
        titulo: libro.titulo,
        portadaUrl: libro.portadaUrl,
        precio: libro.precio,
        cantidad: 1,
      ));
    }
    notifyListeners();
    await _guardarEnStorage();
  }

  Future<void> eliminar(String libroId) async {
    _items.removeWhere((item) => item.libroId == libroId);
    notifyListeners();
    await _guardarEnStorage();
  }

  Future<void> aumentarCantidad(String libroId) async {
    final index = _items.indexWhere((item) => item.libroId == libroId);
    if (index != -1) {
      _items[index].cantidad++;
      notifyListeners();
      await _guardarEnStorage();
    }
  }

  Future<void> disminuirCantidad(String libroId) async {
    final index = _items.indexWhere((item) => item.libroId == libroId);
    if (index != -1) {
      if (_items[index].cantidad <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].cantidad--;
      }
      notifyListeners();
      await _guardarEnStorage();
    }
  }

  Future<void> limpiarCarrito() async {
    _items.clear();
    notifyListeners();
    await _guardarEnStorage();
  }

  Future<void> confirmarPedido({
    required String usuarioId,
    required String metodoPago,
    String direccion = '',
  }) async {
    _cargando = true;
    notifyListeners();

    try {
      final pedido = PedidoModelo(
        id: const Uuid().v4(),
        usuarioId: usuarioId,
        items: _items.map((item) => item.copyWith()).toList(),
        subtotal: total,
        total: total,
        estado: 'pendiente',
        metodoPago: metodoPago,
        direccion: direccion,
        createdAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedido.id)
          .set(pedido.toMap());

      _items.clear();
      await _guardarEnStorage();
      _cargando = false;
      notifyListeners();
    } catch (e) {
      _cargando = false;
      notifyListeners();
      rethrow;
    }
  }
}
