import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      surface: AppColors.darkBackgroundColor,
      onSurface: Colors.grey[400]!, // Use grey instead of white
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    appBarTheme: AppBarTheme(color: AppColors.gray[900]),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey[400]),
      bodyMedium: TextStyle(color: Colors.grey[400]),
      bodySmall: TextStyle(color: Colors.grey[400]),
    ),
  );
}
