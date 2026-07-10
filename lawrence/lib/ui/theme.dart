import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidTheme {
  // Cores Primárias Curadas (Estética Premium Dark Mode)
  static const Color background = Color(0xFF0D0F12);
  static const Color surface = Color(0xFF16191E);
  static const Color primary = Color(0xFFE2A0B7); // Rosa Pastel Soft
  static const Color secondary = Color(0xFF9E8CF2); // Violeta Soft
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color accentGold = Color(
    0xFFF59E0B,
  ); // Ouro para destaques de indicações
  static const Color warningPastel = Color(
    0xFFF87171,
  ); // Rosa avermelhado pastel para alertas

  // Gradiente Principal (Aura Efeito Neon sutil)
  static const LinearGradient auraGradient = LinearGradient(
    colors: [Color(0xFFE2A0B7), Color(0xFF9E8CF2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Efeito Liquid Glass (Fundo Translúcido com Desfoque)
  static BoxDecoration glassDecoration({
    double blurOpacity = 0.08,
    double borderOpacity = 0.12,
    double radius = 16,
  }) {
    return BoxDecoration(
      color: textPrimary.withOpacity(blurOpacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: textPrimary.withOpacity(borderOpacity),
        width: 1.0,
      ),
    );
  }

  // Desfoque de Vidro Deslizante (BackdropFilter blur)
  static ImageFilter glassBlur() {
    return ImageFilter.blur(sigmaX: 15, sigmaY: 15);
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      fontFamily: 'Outfit',
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),
    );
  }
}
