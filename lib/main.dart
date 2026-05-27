import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/firebase_options.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/routes.dart';
import 'package:tinta_y_hojas/nucleo/tema/tema.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/libros/proveedores/libro_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/carrito_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/carrito/proveedores/pedido_provider.dart';
import 'package:tinta_y_hojas/funcionalidades/administracion/proveedores/admin_provider.dart';

late final AuthProvider authProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  authProvider = AuthProvider();
  runApp(const TintaYHojasApp());
}

class TintaYHojasApp extends StatelessWidget {
  const TintaYHojasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => LibroProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
        ChangeNotifierProvider(create: (_) => PedidoProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp.router(
        title: 'Tinta & Hojas',
        theme: TintaYHojasTheme.theme,
        routerConfig: crearRouter(authProvider),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
