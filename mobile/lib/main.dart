import 'package:flutter/material.dart';
import 'package:mobile/screens/login_screen.dart';

void main() {
  runApp(const VirtumApp());
}

class VirtumApp extends StatelessWidget {
  const VirtumApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF667EEA);
    const secondary = Color(0xFF764BA2);
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(
        color: Color(0xFFE2E8F0),
        width: 2,
      ),
    );

    return MaterialApp(
      title: 'VIRTUM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: primary),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: primary,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: secondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            backgroundColor: Colors.white,
            side: const BorderSide(color: primary, width: 2),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
          focusedErrorBorder: inputBorder.copyWith(
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
