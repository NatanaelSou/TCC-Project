import 'package:flutter/material.dart';
import '../constants.dart';

class ThemeNotifier extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeData get currentTheme => _isDark ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary, // Light blue
    scaffoldBackgroundColor: AppColors.background, // White
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background, // White
      foregroundColor: AppColors.textDark, // Black
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark), // Black
      bodyMedium: TextStyle(color: AppColors.textGrey), // Grey
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary, // Lilac
        foregroundColor: AppColors.textLight, // White
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.secondary), // Lilac border
        foregroundColor: AppColors.textDark, // Black
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputFill, // White
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: BorderSide(color: AppColors.primary), // Light blue
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: BorderSide(color: AppColors.secondary), // Lilac
      ),
    ),
    // cardTheme: CardTheme(
    //   color: AppColors.cardBg, // White
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
    //   ),
    // ),
    // Add more customizations as needed
  );

  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary, // Light blue (adjust for dark if needed)
    scaffoldBackgroundColor: Colors.grey[900], // Dark background
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: AppColors.textLight, // White
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.textLight), // White
      bodyMedium: TextStyle(color: Colors.grey[300]), // Light grey
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary, // Lilac
        foregroundColor: AppColors.textLight, // White
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.secondary), // Lilac border
        foregroundColor: AppColors.textLight, // White
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: BorderSide(color: AppColors.primary), // Light blue
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        borderSide: BorderSide(color: AppColors.secondary), // Lilac
      ),
    ),
    // cardTheme: CardTheme(
    //   color: Colors.grey[800],
    //   elevation: 4,
    //   shape: RoundedRectangleBorder(
    //     borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
    //   ),
    // ),
    // Add more customizations as needed
  );
}
