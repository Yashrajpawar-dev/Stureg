import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Spider-Man Theme Color Palette & Design System
class SpiderColors {
  // Primary Spider Reds
  static const Color spiderRed = Color(0xFFE23636);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color deepRed = Color(0xFF7F0909);
  static const Color neonRed = Color(0xFFFF4141);

  // Superhero Blues & Dark Suit Backgrounds
  static const Color heroBlue = Color(0xFF1976D2);
  static const Color electricBlue = Color(0xFF38BDF8);
  static const Color darkBlue = Color(0xFF0A0F1E);
  static const Color deepBlue = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF161F36);
  static const Color cardDarkElevated = Color(0xFF1E294B);

  // Accents
  static const Color goldAccent = Color(0xFFFFD700);
  static const Color webColor = Color(0x33E23636);
  static const Color subtleWeb = Color(0x1FFFFFFF);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderGlow = Color(0x66E23636);
}

/// Global Spider-Man Theme for ThemeData
ThemeData getSpiderManTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: SpiderColors.darkBlue,
    primaryColor: SpiderColors.spiderRed,
    colorScheme: const ColorScheme.dark(
      primary: SpiderColors.spiderRed,
      onPrimary: Colors.white,
      secondary: SpiderColors.heroBlue,
      onSecondary: Colors.white,
      surface: SpiderColors.cardDark,
      onSurface: Colors.white,
      error: Color(0xFFFF5252),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SpiderColors.cardDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
      iconTheme: IconThemeData(color: SpiderColors.spiderRed),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SpiderColors.spiderRed,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: SpiderColors.spiderRed.withValues(alpha: 0.5),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: SpiderColors.electricBlue,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: SpiderColors.cardDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: SpiderColors.textSecondary),
      hintStyle: const TextStyle(color: SpiderColors.textMuted),
      prefixIconColor: SpiderColors.spiderRed,
      suffixIconColor: SpiderColors.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E3B5E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2E3B5E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: SpiderColors.spiderRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF5252), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF5252), width: 2),
      ),
    ),
  );
}

/// Custom Background Painter for Spider-Man Web Aesthetics
class SpiderWebPainter extends CustomPainter {
  final Color webColor;
  final bool showCornerWeb;
  final bool showCenterWeb;

  SpiderWebPainter({
    this.webColor = const Color(0x18FFFFFF),
    this.showCornerWeb = true,
    this.showCenterWeb = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = webColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Corner Spider Web in Top-Right
    if (showCornerWeb) {
      final cornerOrigin = Offset(size.width, 0);
      const numCornerRays = 8;
      const double maxCornerR = 260.0;

      for (int i = 0; i <= numCornerRays; i++) {
        final angle = (math.pi / 2) * (i / numCornerRays) + (math.pi / 2);
        final x = cornerOrigin.dx + maxCornerR * math.cos(angle);
        final y = cornerOrigin.dy + maxCornerR * math.sin(angle);
        canvas.drawLine(cornerOrigin, Offset(x, y), paint);
      }

      for (double r = 40; r <= maxCornerR; r += 45) {
        final path = Path();
        for (int i = 0; i <= numCornerRays; i++) {
          final angle = (math.pi / 2) * (i / numCornerRays) + (math.pi / 2);
          final x = cornerOrigin.dx + r * math.cos(angle);
          final y = cornerOrigin.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(path, paint);
      }
    }

    // Subtle Center/Bottom Web Pattern
    if (showCenterWeb) {
      final centerOrigin = Offset(size.width * 0.15, size.height * 0.85);
      const numRays = 7;
      const double maxR = 220.0;

      for (int i = 0; i < numRays; i++) {
        final angle = (math.pi) * (i / (numRays - 1)) - (math.pi / 4);
        final x = centerOrigin.dx + maxR * math.cos(angle);
        final y = centerOrigin.dy + maxR * math.sin(angle);
        canvas.drawLine(centerOrigin, Offset(x, y), paint);
      }

      for (double r = 40; r <= maxR; r += 45) {
        final path = Path();
        for (int i = 0; i < numRays; i++) {
          final angle = (math.pi) * (i / (numRays - 1)) - (math.pi / 4);
          final x = centerOrigin.dx + r * math.cos(angle);
          final y = centerOrigin.dy + r * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Official Spider-Man App Logo Widget
class SpidermanAppLogo extends StatelessWidget {
  final double size;
  final bool showGlow;
  final bool heroTag;

  const SpidermanAppLogo({
    super.key,
    this.size = 100,
    this.showGlow = true,
    this.heroTag = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget logoContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: SpiderColors.spiderRed.withValues(alpha: 0.55),
                  blurRadius: size * 0.25,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: SpiderColors.electricBlue.withValues(alpha: 0.2),
                  blurRadius: size * 0.4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/images/spiderman_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Elegant fallback if asset loading is ever delayed
            return Container(
              color: SpiderColors.cardDark,
              child: Center(
                child: Icon(
                  Icons.shield_rounded,
                  size: size * 0.6,
                  color: SpiderColors.spiderRed,
                ),
              ),
            );
          },
        ),
      ),
    );

    if (heroTag) {
      return Hero(
        tag: 'spiderman_app_logo',
        child: logoContent,
      );
    }

    return logoContent;
  }
}

/// Spider Emblem Insignia Icon Widget
class SpiderEmblemIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const SpiderEmblemIcon({
    super.key,
    this.size = 32,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/spiderman_emblem.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.bug_report,
          size: size,
          color: color ?? SpiderColors.spiderRed,
        );
      },
    );
  }
}

/// Superhero Styled Card with Red & Blue Glow Accents
class SpiderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool hasGlow;

  const SpiderCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SpiderColors.cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasGlow ? SpiderColors.spiderRed.withValues(alpha: 0.4) : const Color(0xFF222E4E),
          width: 1.5,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: SpiderColors.spiderRed.withValues(alpha: 0.18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }
}
