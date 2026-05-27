import 'package:flutter/material.dart';
import 'package:tinta_y_hojas/nucleo/configuracion/constantes.dart';

class CampoTexto extends StatelessWidget {
  final TextEditingController? controlador;
  final String? etiqueta;
  final String? ayuda;
  final bool obscureText;
  final TextInputType tipoTeclado;
  final String? Function(String?)? validador;
  final IconData? iconoPrefijo;
  final Widget? iconoSufijo;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? maxLength;

  const CampoTexto({
    super.key,
    this.controlador,
    this.etiqueta,
    this.ayuda,
    this.obscureText = false,
    this.tipoTeclado = TextInputType.text,
    this.validador,
    this.iconoPrefijo,
    this.iconoSufijo,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      obscureText: obscureText,
      keyboardType: tipoTeclado,
      validator: validador,
      onChanged: onChanged,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Constantes.textDark),
      decoration: InputDecoration(
        labelText: etiqueta,
        hintText: ayuda,
        labelStyle: const TextStyle(fontFamily: 'Inter', color: Constantes.textDark),
        hintStyle: TextStyle(fontFamily: 'Inter', color: Constantes.textDark.withAlpha(128)),
        prefixIcon: iconoPrefijo != null ? Icon(iconoPrefijo, color: Constantes.vinoSoft) : null,
        suffixIcon: iconoSufijo,
        filled: true,
        fillColor: Constantes.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Constantes.vinoSoft.withAlpha(128)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Constantes.vinoSoft.withAlpha(128)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Constantes.vinoPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
