import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  const AppTheme._();

  static const Color navy = Color(0xFF0B1F3A);
  static const Color deepTeal = Color(0xFF006D77);
  static const Color accent = Color(0xFF22B8A8);
  static const Color softBg = Color(0xFFF3F7FA);

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: softBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepTeal,
        primary: deepTeal,
        secondary: accent,
        surface: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: navy,
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: const EdgeInsets.all(0),
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8E0E8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD8E0E8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: deepTeal, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: deepTeal,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF071425),
        foregroundColor: Colors.white,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
