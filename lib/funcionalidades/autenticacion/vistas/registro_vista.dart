import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tinta_y_hojas/funcionalidades/autenticacion/proveedores/auth_provider.dart';
import 'package:tinta_y_hojas/compartido/componentes/campo_texto.dart';
import 'package:tinta_y_hojas/nucleo/utilidades/validadores.dart';

class RegistroVista extends StatefulWidget {
  const RegistroVista({super.key});

  @override
  State<RegistroVista> createState() => _RegistroVistaState();
}

class _RegistroVistaState extends State<RegistroVista> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmar = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    await auth.registrar(
      nombre: _nombreController.text.trim(),
      correo: _emailController.text.trim(),
      contrasena: _passwordController.text,
      telefono: _telefonoController.text.trim(),
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
          content: const Text('Cuenta creada exitosamente'),
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
                  const Icon(Icons.menu_book, size: 64, color: Color(0xFF7B2D42)),
                  const SizedBox(height: 12),
                  Text(
                    'Crear Cuenta',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa tus datos para registrarte',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  CampoTexto(
                    controlador: _nombreController,
                    etiqueta: 'Nombre completo',
                    iconoPrefijo: Icons.person_outlined,
                    validador: (v) => Validadores.validarCampoVacio(v, 'El nombre'),
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    controlador: _emailController,
                    etiqueta: 'Correo electrónico',
                    iconoPrefijo: Icons.email_outlined,
                    tipoTeclado: TextInputType.emailAddress,
                    validador: Validadores.validarEmail,
                  ),
                  const SizedBox(height: 14),
                  CampoTexto(
                    controlador: _telefonoController,
                    etiqueta: 'Teléfono (opcional)',
                    iconoPrefijo: Icons.phone_outlined,
                    tipoTeclado: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
                  CampoTexto(
                    controlador: _confirmarController,
                    etiqueta: 'Confirmar contraseña',
                    obscureText: _obscureConfirmar,
                    iconoPrefijo: Icons.lock_outlined,
                    iconoSufijo: IconButton(
                      icon: Icon(
                        _obscureConfirmar ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                    ),
                    validador: (v) => Validadores.validarConfirmarContrasena(v, _passwordController.text),
                  ),
                  const SizedBox(height: 24),
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.cargando ? null : _registrar,
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
                                  'Crear Cuenta',
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
                      context.go('/login');
                    },
                    child: const Text('¿Ya tienes cuenta? Inicia sesión'),
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
