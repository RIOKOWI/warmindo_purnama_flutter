import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radius.dart';

/// Neo Brutalism theme for Warmindo Purnama
class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          onPrimary: Colors.white,
          secondary: AppColors.dark,
          onSecondary: Colors.white,
          surface: AppColors.card,
          onSurface: AppColors.text,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          iconTheme: IconThemeData(color: AppColors.text),
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
            side: const BorderSide(color: AppColors.dark, width: 3),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
              side: const BorderSide(color: AppColors.dark, width: 3),
            ),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.text,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
              side: const BorderSide(color: AppColors.dark, width: 3),
            ),
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.text,
            textStyle: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: AppRadius.textField,
            borderSide: const BorderSide(color: AppColors.dark, width: 3),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.textField,
            borderSide: const BorderSide(color: AppColors.dark, width: 3),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.textField,
            borderSide: const BorderSide(color: AppColors.accent, width: 3),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.textField,
            borderSide: const BorderSide(color: AppColors.error, width: 3),
          ),
          labelStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          hintStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.dialog,
            side: const BorderSide(color: AppColors.dark, width: 3),
          ),
        ),
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.bottomSheet,
            side: const BorderSide(color: AppColors.dark, width: 3),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.dark,
          contentTextStyle: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          behavior: SnackBarBehavior.floating,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
            side: const BorderSide(color: AppColors.dark, width: 3),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.dark,
          thickness: 3,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.text,
          size: 24,
        ),
      );
}
