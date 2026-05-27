import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/vistas/login_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/vistas/registro_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/vistas/recuperar_password_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/libros/vistas/home_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/libros/vistas/detalle_libro_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/vistas/carrito_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/vistas/checkout_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/vistas/mis_pedidos_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/perfil/vistas/perfil_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/perfil/vistas/editar_perfil_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/perfil/vistas/favoritos_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_home_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_libros_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_usuarios_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_pedidos_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_categorias_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_autores_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_editoriales_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_idiomas_vista.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/vistas/admin_proveedores_vista.dart';

GoRouter crearRouter(AuthProvider authProvider) {
  return GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/login',
    redirect: (context, state) {
      final estaAutenticado = authProvider.estaAutenticado;
      final esAdmin = authProvider.esAdmin;
      final ubicacion = state.uri.toString();

      final rutasPublicas = ['/login', '/registro', '/recuperar-password'];
      final esRutaPublica = rutasPublicas.any((r) => ubicacion == r);
      final esRutaAdmin = ubicacion.startsWith('/admin');

      if (!estaAutenticado && !esRutaPublica) {
        return '/login';
      }
      if (estaAutenticado && esRutaPublica) {
        return '/home';
      }
      if (estaAutenticado && esRutaAdmin && !esAdmin) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', name: 'login', pageBuilder: (_, s) => _fadePage(const LoginVista(), key: s.pageKey)),
      GoRoute(path: '/registro', name: 'registro', pageBuilder: (_, s) => _fadePage(const RegistroVista(), key: s.pageKey)),
      GoRoute(path: '/recuperar-password', name: 'recuperarPassword', pageBuilder: (_, s) => _fadePage(const RecuperarPasswordVista(), key: s.pageKey)),
      GoRoute(path: '/', redirect: (_, __) => '/home'),
      GoRoute(path: '/home', name: 'home', pageBuilder: (_, s) => _fadePage(const HomeVista(), key: s.pageKey)),
      GoRoute(
        path: '/libro/:id',
        name: 'detalleLibro',
        pageBuilder: (_, s) => _fadePage(DetalleLibroVista(libroId: s.pathParameters['id']!), key: s.pageKey),
      ),
      GoRoute(path: '/carrito', name: 'carrito', pageBuilder: (_, s) => _fadePage(const CarritoVista(), key: s.pageKey)),
      GoRoute(path: '/checkout', name: 'checkout', pageBuilder: (_, s) => _fadePage(const CheckoutVista(), key: s.pageKey)),
      GoRoute(path: '/mis-pedidos', name: 'misPedidos', pageBuilder: (_, s) => _fadePage(const MisPedidosVista(), key: s.pageKey)),
      GoRoute(path: '/perfil', name: 'perfil', pageBuilder: (_, s) => _fadePage(const PerfilVista(), key: s.pageKey)),
      GoRoute(path: '/editar-perfil', name: 'editarPerfil', pageBuilder: (_, s) => _fadePage(const EditarPerfilVista(), key: s.pageKey)),
      GoRoute(path: '/favoritos', name: 'favoritos', pageBuilder: (_, s) => _fadePage(const FavoritosVista(), key: s.pageKey)),
      GoRoute(
        path: '/admin',
        name: 'admin',
        pageBuilder: (_, s) => _fadePage(const AdminHomeVista(), key: s.pageKey),
        routes: [
          GoRoute(path: 'libros', name: 'adminLibros', pageBuilder: (_, s) => _fadePage(const AdminLibrosVista(), key: s.pageKey)),
          GoRoute(path: 'usuarios', name: 'adminUsuarios', pageBuilder: (_, s) => _fadePage(const AdminUsuariosVista(), key: s.pageKey)),
          GoRoute(path: 'pedidos', name: 'adminPedidos', pageBuilder: (_, s) => _fadePage(const AdminPedidosVista(), key: s.pageKey)),
          GoRoute(path: 'categorias', name: 'adminCategorias', pageBuilder: (_, s) => _fadePage(const AdminCategoriasVista(), key: s.pageKey)),
          GoRoute(path: 'autores', name: 'adminAutores', pageBuilder: (_, s) => _fadePage(const AdminAutoresVista(), key: s.pageKey)),
          GoRoute(path: 'editoriales', name: 'adminEditoriales', pageBuilder: (_, s) => _fadePage(const AdminEditorialesVista(), key: s.pageKey)),
          GoRoute(path: 'idiomas', name: 'adminIdiomas', pageBuilder: (_, s) => _fadePage(const AdminIdiomasVista(), key: s.pageKey)),
          GoRoute(path: 'proveedores', name: 'adminProveedores', pageBuilder: (_, s) => _fadePage(const AdminProveedoresVista(), key: s.pageKey)),
        ],
      ),
    ],
  );
}

Page<dynamic> _fadePage(Widget child, {ValueKey<String>? key}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );
}
