import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/campo_texto.dart';
import 'package:tinta_y_hojas/nucleo/utilidades/validadores.dart';

class RecuperarPasswordVista extends StatefulWidget {
  const RecuperarPasswordVista({super.key});

  @override
  State<RecuperarPasswordVista> createState() => _RecuperarPasswordVistaState();
}

class _RecuperarPasswordVistaState extends State<RecuperarPasswordVista> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarEnlace() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.recuperarPassword(_emailController.text.trim());

    if (!mounted) return;

    if (auth.errorMensaje != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMensaje!),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enlace de recuperación enviado a tu correo'),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar Contraseña'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_reset, size: 72, color: Color(0xFF7B2D42)),
                  const SizedBox(height: 16),
                  Text(
                    '¿Olvidaste tu contraseña?',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa tu correo y te enviaremos un enlace para restablecerla.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CampoTexto(
                    controlador: _emailController,
                    etiqueta: 'Correo electrónico',
                    iconoPrefijo: Icons.email_outlined,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: Validadores.validarEmail,
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.cargando ? null : _enviarEnlace,
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
                                  'Enviar enlace de recuperación',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Volver al inicio de sesión'),
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
