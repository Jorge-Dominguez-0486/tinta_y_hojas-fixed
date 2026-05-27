class Validadores {
  Validadores._();

  static String? validarEmail(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El correo electrónico es requerido';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(valor.trim())) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  static String? validarContrasena(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'La contraseña es requerida';
    }
    if (valor.trim().length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validarCampoVacio(String? valor, [String nombre = 'Este campo']) {
    if (valor == null || valor.trim().isEmpty) {
      return '$nombre es requerido';
    }
    return null;
  }

  static String? validarConfirmarContrasena(String? valor, String contrasena) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Confirme su contraseña';
    }
    if (valor.trim() != contrasena) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validarPrecio(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'El precio es requerido';
    }
    final precio = double.tryParse(valor.trim());
    if (precio == null || precio <= 0) {
      return 'Ingrese un precio válido mayor a 0';
    }
    return null;
  }
}
