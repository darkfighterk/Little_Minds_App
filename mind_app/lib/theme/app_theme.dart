import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const String _themeKey = 'user_theme_mode';

  // Global Theme Notifier
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  /// Loads the saved theme from internal storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.system;
    }
  }

  /// Saves the user's theme preference
  static Future<void> saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String modeString = 'system';
    if (mode == ThemeMode.light) modeString = 'light';
    if (mode == ThemeMode.dark) modeString = 'dark';

    await prefs.setString(_themeKey, modeString);
  }

  // Core Brand Colors
  static const Color mainBlue = Color(0xFF3AAFFF);
  static const Color darkBg = Color(0xFF12111A);
  static const Color warmBg = Color(0xFFFFF8EE);
  static const Color darkCard = Color(0xFF1E1C2A);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: mainBlue,
      scaffoldBackgroundColor: warmBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mainBlue,
        brightness: Brightness.light,
        primary: mainBlue,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.light().textTheme),
      cardColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black87),
      appBarTheme: const AppBarTheme(
        backgroundColor: warmBg,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Recoleta'),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: mainBlue,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mainBlue,
        brightness: Brightness.dark,
        primary: mainBlue,
        surface: darkCard,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      cardColor: darkCard,
      iconTheme: const IconThemeData(color: Colors.white),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Recoleta'),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
