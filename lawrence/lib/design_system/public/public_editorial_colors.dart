import 'package:flutter/widgets.dart';

/// Public-facing palette for the Maison Lawrence editorial experience.
///
/// Gold is decorative only on light surfaces. Functional text and actions use
/// ink, plum or wine so normal-sized copy always has a WCAG AA-safe pair.
abstract final class PublicEditorialColors {
  static const ink = Color(0xFF1A0B10);
  static const noir = Color(0xFF100C0D);
  static const plum = Color(0xFF2C111B);
  static const wine = Color(0xFF6B1328);
  static const ruby = Color(0xFF811D3B);
  static const ivory = Color(0xFFF7F0E8);
  static const parchment = Color(0xFFE9DECF);
  static const antiqueRose = Color(0xFFCFA9A8);
  static const antiqueGold = Color(0xFFB38A4A);
  static const champagne = Color(0xFFE8D2B0);
  static const mutedInk = Color(0xFF6A5B60);
  static const white = Color(0xFFFFFFFF);

  static const focusLight = ivory;
  static const focusDark = wine;

  // Compatibility aliases for public pages being migrated to the new system.
  static const black = noir;
  static const pureBlack = noir;
  static const navy = wine;
  static const navyLight = ruby;
  static const navyDark = plum;
  static const gold = antiqueGold;
  static const goldLight = champagne;
  static const goldBright = champagne;
  static const goldDark = antiqueGold;
  static const goldShadow = Color(0xFF765326);
  static const goldSubtle = Color(0x26B38A4A);
  static const goldFoil = <Color>[
    goldShadow,
    antiqueGold,
    champagne,
    antiqueGold,
  ];
  static const wine900 = ink;
  static const wine800 = plum;
  static const wine700 = wine;
  static const wine600 = ruby;
  static const warmGray = mutedInk;
}
