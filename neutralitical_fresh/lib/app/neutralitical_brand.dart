import 'package:flutter/material.dart';

abstract final class NeutraliticalBrand {
  static const String iconAsset = 'assets/branding/neutralitical_icon.png';
  static const String markAsset = 'assets/branding/neutralitical_mark_512.png';

  static const Color forest = Color(0xFF16473C);
  static const Color sage = Color(0xFF35685A);
  static const Color moss = Color(0xFF6D8F7B);
  static const Color gold = Color(0xFFD8B15E);
  static const Color cream = Color(0xFFF7F4EC);
  static const Color sand = Color(0xFFE9DEC9);
  static const Color ink = Color(0xFF1D2622);

  static const LinearGradient shellGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3EEDF), Color(0xFFF9F6EF), Color(0xFFECE3D1)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forest, sage],
  );
}
