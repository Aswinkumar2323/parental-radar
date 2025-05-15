import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  useMaterial3: true,

  // ✅ Apply Righteous font globally
  textTheme: GoogleFonts.righteousTextTheme(),

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4B39EF),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: const Color(0xFFF3F4F6),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: Color(0xFF1F2937),
      fontWeight: FontWeight.bold,
      fontSize: 22,
      fontFamily: 'Righteous', // Optional: ensure Righteous is used here too
    ),
    iconTheme: IconThemeData(color: Color(0xFF4B5563)),
  ),

  cardTheme: CardTheme(
    elevation: 4,
    shadowColor: Colors.black12,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(12),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4B39EF),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: 'Righteous', // Optional: reinforce usage in button text
      ),
    ),
  ),
);
