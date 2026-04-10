import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFF0A0A0F);
  static const Color surface = Color(0xFF13131A);
  static const Color card = Color(0xFF1C1C28);
  static const Color primary = Color(0xFFFF2D55);
  static const Color primaryDim = Color(0xFF7A0F25);
  static const Color accent = Color(0xFFFFD700);
  static const Color textPrimary = Color(0xFFF0F0FF);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color divider = Color(0xFF2A2A3A);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF12121E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Color(0x44FF2D55), Color(0x00FF2D55)],
    radius: 0.85,
  );

  // ── Shadows ──────────────────────────────────────────────────────────────
  static List<BoxShadow> glowShadow = [
    BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 20,
      spreadRadius: -4,
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  // ── Decorations ──────────────────────────────────────────────────────────
  static BoxDecoration glassDecoration({double radius = 20}) => BoxDecoration(
        color: card.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: cardShadow,
      );

  static BoxDecoration primaryButtonDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(14),
    boxShadow: glowShadow,
  );

  // ── Text Styles ──────────────────────────────────────────────────────────
  static TextStyle headline(double size) => GoogleFonts.outfit(
        color: textPrimary,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle body(double size, {Color? color}) => GoogleFonts.outfit(
        color: color ?? textSecondary,
        fontSize: size,
        fontWeight: FontWeight.w400,
      );

  static TextStyle label(double size, {Color? color}) => GoogleFonts.outfit(
        color: color ?? textPrimary,
        fontSize: size,
        fontWeight: FontWeight.w600,
      );

  // ── Input Decoration ─────────────────────────────────────────────────────
  static InputDecoration cinemaInput({
    required String hint,
    IconData? icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: body(14),
        prefixIcon: icon != null
            ? Icon(icon, color: textSecondary, size: 20)
            : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
      );

  // ── Theme ────────────────────────────────────────────────────────────────
  static ThemeData darkTheme() => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: primary,
          surface: surface,
          onSurface: textPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: GoogleFonts.outfit(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: textPrimary),
        ),
        textTheme: GoogleFonts.outfitTextTheme().apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: card,
          contentTextStyle: GoogleFonts.outfit(color: textPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
      );
}

// ── Custom page transition ────────────────────────────────────────────────────
class CinemaRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  CinemaRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 450),
          reverseTransitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            const begin = Offset(0.04, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        );
}
