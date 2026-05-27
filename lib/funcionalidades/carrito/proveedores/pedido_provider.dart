import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tinta_y_hojas/compartido/modelos/pedido_modelo.dart';

class PedidoProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<PedidoModelo> _pedidos = [];
  bool _cargando = false;
  String? _mensajeError;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<PedidoModelo> get pedidos => _pedidos;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  void escucharPedidos(String usuarioId) {
    _subscription?.cancel();
    _cargando = true;
    notifyListeners();

    _subscription = _firestore
        .collection('pedidos')
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _pedidos = snapshot.docs
                .map((doc) => PedidoModelo.fromMap(doc.data()))
                .toList();
            _cargando = false;
            _mensajeError = null;
            notifyListeners();
          },
          onError: (e) {
            _mensajeError = 'Error al cargar pedidos: $e';
            _cargando = false;
            notifyListeners();
          },
        );
  }

  void escucharTodosLosPedidos() {
    _subscription?.cancel();
    _cargando = true;
    notifyListeners();

    _subscription = _firestore
        .collection('pedidos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _pedidos = snapshot.docs
                .map((doc) => PedidoModelo.fromMap(doc.data()))
                .toList();
            _cargando = false;
            _mensajeError = null;
            notifyListeners();
          },
          onError: (e) {
            _mensajeError = 'Error al cargar pedidos: $e';
            _cargando = false;
            notifyListeners();
          },
        );
  }

  Future<void> crearPedido(PedidoModelo pedido) async {
    try {
      await _firestore.collection('pedidos').doc(pedido.id).set(pedido.toMap());
    } catch (e) {
      _mensajeError = 'Error al crear pedido: $e';
      notifyListeners();
    }
  }

  Future<void> actualizarEstado(String pedidoId, String estado) async {
    try {
      await _firestore.collection('pedidos').doc(pedidoId).update({
        'estado': estado,
      });
    } catch (e) {
      _mensajeError = 'Error al actualizar estado: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
