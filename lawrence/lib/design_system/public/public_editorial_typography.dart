import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class PublicEditorialTypography {
  static TextStyle heroDisplay(BuildContext context, {Color? color}) {
    final width = MediaQuery.sizeOf(context).width;
    final size = width >= 1100
        ? (width * 0.066).clamp(72.0, 108.0)
        : width >= 700
        ? 64.0
        : (width * 0.125).clamp(44.0, 58.0);
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? const Color(0xFFF7F0E8),
      height: 0.94,
      letterSpacing: -1.4,
    );
  }

  static TextStyle sectionDisplay({Color? color, double size = 72}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? const Color(0xFF1A0B10),
      height: 0.96,
      letterSpacing: -0.8,
    );
  }

  static TextStyle storyDisplay({Color? color}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: 52,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
      color: color ?? const Color(0xFF1A0B10),
      height: 1.02,
    );
  }

  static TextStyle courseTitle({Color? color}) =>
      sectionDisplay(color: color, size: 42);

  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: color ?? const Color(0xFF1A0B10),
    height: 1.65,
  );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: color ?? const Color(0xFF1A0B10),
    height: 1.58,
  );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: color ?? const Color(0xFF6A5B60),
    height: 1.5,
  );

  static TextStyle eyebrow({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.2,
    color: color ?? const Color(0xFF1A0B10),
    height: 1.25,
  );

  static TextStyle buttonLabel({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: color ?? const Color(0xFFFFFFFF),
    height: 1.2,
  );
}
