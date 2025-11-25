import 'package:flutter/material.dart';

class AppColors {
static const primary = Color(0xFFEF3B2D); // rojo intenso
static const secondary = Color(0xFF1E88E5); // azul llamativo
static const accent = Color(0xFFFFC107); // amarillo brillante
static const background = Color(0xFFF5F5F5); // gris claro
static const textDark = Color(0xFF212121);
static const textLight = Colors.white;
}

class AppTheme {
static ThemeData lightTheme = ThemeData(
useMaterial3: true,
colorScheme: ColorScheme.fromSeed(
seedColor: AppColors.primary,
primary: AppColors.primary,
secondary: AppColors.secondary,
),
scaffoldBackgroundColor: AppColors.background,
appBarTheme: AppBarTheme(
backgroundColor: AppColors.primary,
foregroundColor: AppColors.textLight,
elevation: 4,
centerTitle: true,
),
elevatedButtonTheme: ElevatedButtonThemeData(
style: ElevatedButton.styleFrom(
backgroundColor: AppColors.primary,
foregroundColor: AppColors.textLight,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
),
),
textButtonTheme: TextButtonThemeData(
style: TextButton.styleFrom(
foregroundColor: AppColors.secondary,
textStyle: TextStyle(fontWeight: FontWeight.bold),
),
),
inputDecorationTheme: InputDecorationTheme(
border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
filled: true,
fillColor: Colors.white,
contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
labelStyle: TextStyle(color: AppColors.textDark),
),
cardTheme: CardThemeData(
color: Colors.white,
elevation: 4,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
),
);
}
