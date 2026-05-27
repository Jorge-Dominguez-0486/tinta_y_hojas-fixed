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

  String? _uidActivo;

  List<PedidoModelo> get pedidos => _pedidos;
  bool get cargando => _cargando;
  String? get mensajeError => _mensajeError;

  void escucharPedidos(String usuarioId) {
    if (_uidActivo == usuarioId && _subscription != null) return;

    _uidActivo = usuarioId;
    _subscription?.cancel();
    _subscription = null;

    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    _subscription = _firestore
        .collection('pedidos')
        .where('usuarioId', isEqualTo: usuarioId)
        .snapshots()
        .listen(
          (snapshot) {
            final lista = snapshot.docs
                .map((doc) {
                  try {
                    return PedidoModelo.fromMap(
                      doc.data(),
                    );
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<PedidoModelo>()
                .toList();

            lista.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            _pedidos = lista;
            _cargando = false;
            _mensajeError = null;
            notifyListeners();
          },
          onError: (e) {
            _mensajeError = e.toString();
            _cargando = false;
            notifyListeners();
          },
        );
  }

  void escucharTodosLosPedidos() {
    _uidActivo = null;
    _subscription?.cancel();
    _subscription = null;

    _cargando = true;
    _mensajeError = null;
    notifyListeners();

    _subscription = _firestore
        .collection('pedidos')
        .snapshots()
        .listen(
          (snapshot) {
            final lista = snapshot.docs
                .map((doc) {
                  try {
                    return PedidoModelo.fromMap(
                      doc.data(),
                    );
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<PedidoModelo>()
                .toList();

            lista.sort((a, b) => b.createdAt.compareTo(a.createdAt));

            _pedidos = lista;
            _cargando = false;
            _mensajeError = null;
            notifyListeners();
          },
          onError: (e) {
            _mensajeError = e.toString();
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

  void limpiar() {
    _subscription?.cancel();
    _subscription = null;
    _uidActivo = null;
    _pedidos = [];
    _cargando = false;
    _mensajeError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
