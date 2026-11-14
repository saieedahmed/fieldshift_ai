import 'package:flutter/material.dart';

class AppTheme {
  static const forest = Color(0xFF214D3A);
  static const deepForest = Color(0xFF163A2C);
  static const sage = Color(0xFF93AA89);
  static const paleSage = Color(0xFFE7EDE2);
  static const coral = Color(0xFFE47B58);
  static const ivory = Color(0xFFF7F5EE);
  static const ink = Color(0xFF24352D);
  static const mutedInk = Color(0xFF718078);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: forest,
      brightness: brightness,
      primary: isDark ? const Color(0xFF9CC4A8) : forest,
      secondary: coral,
      surface: isDark ? const Color(0xFF1C2922) : ivory,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF121B16) : ivory,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF121B16) : ivory,
        foregroundColor: isDark ? Colors.white : ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1C2922) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: EdgeInsets.zero,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1C2922) : Colors.white,
        indicatorColor: isDark ? const Color(0xFF355743) : paleSage,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        backgroundColor: isDark ? const Color(0xFF2A3A30) : paleSage,
      ),
      textTheme: Typography.material2021().black.apply(
        bodyColor: isDark ? const Color(0xFFE7ECE8) : ink,
        displayColor: isDark ? Colors.white : ink,
      ),
    );
  }
}
