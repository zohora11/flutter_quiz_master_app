import 'package:flutter/material.dart';

/// Centralized design tokens for Quiz Master.
///
/// Keeping every color, gradient and spacing value in one place is what lets
/// the rest of the app look consistent instead of "assembled from parts" —
/// every screen pulls from the same palette.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF8B5CF6); // Violet

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color error = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFDC2626);

  // Neutrals (used for custom surfaces beyond Material defaults)
  static const Color lightBg = Color(0xFFF7F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF1A1D27);

  /// One accent gradient per quiz category — this is what makes the
  /// dashboard feel like a real product instead of identical gray boxes.
  static const List<Color> sports = [Color(0xFFFF7A59), Color(0xFFFFB347)];
  static const List<Color> science = [Color(0xFF06B6D4), Color(0xFF3B82F6)];
  static const List<Color> technology = [Color(0xFF8B5CF6), Color(0xFF6366F1)];
  static const List<Color> history = [Color(0xFFF59E0B), Color(0xFFB45309)];
  static const List<Color> general = [Color(0xFF10B981), Color(0xFF0D9488)];
  static const List<Color> fallback = [Color(0xFF6366F1), Color(0xFF8B5CF6)];

  static List<Color> categoryGradient(String categoryId) {
    switch (categoryId) {
      case 'sports':
        return sports;
      case 'science':
        return science;
      case 'technology':
        return technology;
      case 'history':
        return history;
      case 'general':
        return general;
      default:
        return fallback;
    }
  }
}

class AppRadius {
  AppRadius._();
  static const double sm = 10;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double pill = 999;
}

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> soft(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withOpacity(0.35)
            : const Color(0xFF1E293B).withOpacity(0.06),
        blurRadius: 20,
        offset: const Offset(0, 8),
        spreadRadius: -4,
      ),
    ];
  }

  static List<BoxShadow> colored(Color color) {
    return [
      BoxShadow(
        color: color.withOpacity(0.35),
        blurRadius: 18,
        offset: const Offset(0, 10),
        spreadRadius: -6,
      ),
    ];
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(letterSpacing: -0.2),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(letterSpacing: -0.2),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outlineVariant, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.6),
        thickness: 1,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
    );
  }
}
