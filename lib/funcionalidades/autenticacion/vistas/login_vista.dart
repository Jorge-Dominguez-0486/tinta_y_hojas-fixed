import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/campo_texto.dart';
import 'package:tinta_y_hojas/nucleo/utilidades/validadores.dart';

class LoginVista extends StatefulWidget {
  const LoginVista({super.key});

  @override
  State<LoginVista> createState() => _LoginVistaState();
}

class _LoginVistaState extends State<LoginVista> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.iniciarSesion(
      correo: _emailController.text.trim(),
      contrasena: _passwordController.text,
    );

    if (!mounted) return;

    if (auth.errorMensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMensaje!),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (auth.estaAutenticado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Inicio de sesión exitoso'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 80, color: Color(0xFF7B2D42)),
                  const SizedBox(height: 16),
                  Text(
                    'Tinta & Hojas',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 32,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu librería de confianza',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 40),
                  CampoTexto(
                    controlador: _emailController,
                    etiqueta: 'Correo electrónico',
                    iconoPrefijo: Icons.email_outlined,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: Validadores.validarEmail,
                  ),
                  const SizedBox(height: 16),
                  CampoTexto(
                    controlador: _passwordController,
                    etiqueta: 'Contraseña',
                    obscureText: _obscurePassword,
                    iconoPrefijo: Icons.lock_outlined,
                    iconoSufijo: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validador: Validadores.validarContrasena,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.go('/recuperar-password'),
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.cargando ? null : _iniciarSesion,
                          child: auth.cargando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.read<AuthProvider>().limpiarError();
                      context.go('/registro');
                    },
                    child: const Text('¿No tienes cuenta? Regístrate'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
