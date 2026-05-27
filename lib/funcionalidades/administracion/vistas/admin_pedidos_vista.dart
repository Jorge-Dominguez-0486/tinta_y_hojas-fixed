import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';
import 'package:tinta_y_hojas/compartido/modelos/pedido_modelo.dart';
import 'package:tinta_y_hojas/compartido/componentes/cargando.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';
import 'package:tinta_y_hojas/compartido/componentes/drawer_principal.dart';

class AdminPedidosVista extends StatefulWidget {
  const AdminPedidosVista({super.key});

  @override
  State<AdminPedidosVista> createState() => _AdminPedidosVistaState();
}

class _AdminPedidosVistaState extends State<AdminPedidosVista> {
  String _filtroEstado = 'todos';

  final _estados = ['todos', 'pendiente', 'procesando', 'entregado', 'cancelado'];

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange;
      case 'procesando': return Colors.blue;
      case 'entregado': return Colors.green;
      case 'cancelado': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formato = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: Constantes.beige,
      drawer: const DrawerPrincipal(),
      appBar: AppBar(title: const Text('Gestión de Pedidos')),
      body: StreamBuilder<List<PedidoModelo>>(
        stream: context.read<AdminProvider>().pedidosStream(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Cargando(pantallaCompleta: false, mensaje: 'Cargando pedidos...');
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          var pedidos = snap.data ?? [];
          if (_filtroEstado != 'todos') {
            pedidos = pedidos.where((p) => p.estado == _filtroEstado).toList();
          }

          return Column(
            children: [
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: _estados.length,
                  itemBuilder: (_, i) {
                    final e = _estados[i];
                    final sel = _filtroEstado == e;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(e == 'todos' ? 'Todos' : e[0].toUpperCase() + e.substring(1)),
                        selected: sel,
                        onSelected: (_) => setState(() => _filtroEstado = e),
                        selectedColor: Constantes.vinoPrimary,
                        backgroundColor: Constantes.cream,
                        labelStyle: TextStyle(color: sel ? Colors.white : Constantes.textDark, fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: pedidos.isEmpty
                    ? const Center(child: Text('No hay pedidos'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pedidos.length,
                        itemBuilder: (_, i) {
                          final p = pedidos[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Constantes.cream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Constantes.vinoSoft.withAlpha(60)),
                            ),
                            child: ExpansionTile(
                              shape: const Border(),
                              collapsedShape: const Border(),
                              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('#${p.id.length > 6 ? p.id.substring(0, 6).toUpperCase() : p.id.toUpperCase()}',
                                    style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _colorEstado(p.estado).withAlpha(30),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      p.estado[0].toUpperCase() + p.estado.substring(1),
                                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: _colorEstado(p.estado)),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                '${formato.format(p.total)} MXN • ${DateFormat('dd/MM/yy HH:mm').format(p.createdAt)}',
                                style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Constantes.textDark.withAlpha(150)),
                              ),
                              children: [
                                const Divider(),
                                _infoFila('Usuario ID', p.usuarioId.length > 20 ? '...${p.usuarioId.substring(p.usuarioId.length - 20)}' : p.usuarioId),
                                _infoFila('Método de pago', p.metodoPago),
                                _infoFila('Subtotal', '${formato.format(p.subtotal)} MXN'),
                                _infoFila('Total', '${formato.format(p.total)} MXN'),
                                const SizedBox(height: 8),
                                const Text('Items', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 13, color: Constantes.textDark)),
                                const SizedBox(height: 4),
                                ...p.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Expanded(child: Text(item.titulo, style: const TextStyle(fontFamily: 'Inter', fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      Text('${formato.format(item.precio)} x ${item.cantidad}', style: const TextStyle(fontFamily: 'Inter', fontSize: 11, color: Constantes.textDark)),
                                    ],
                                  ),
                                )),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: p.estado,
                                  decoration: const InputDecoration(
                                    labelText: 'Cambiar estado',
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  items: ['pendiente', 'procesando', 'entregado', 'cancelado'].map((e) => DropdownMenuItem(value: e, child: Text(e[0].toUpperCase() + e.substring(1)))).toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      context.read<AdminProvider>().actualizarEstadoPedido(p.id, v);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoFila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Constantes.textDark.withAlpha(150))),
          Text(valor, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
