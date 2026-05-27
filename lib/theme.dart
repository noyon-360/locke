import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class Lk {
  // ── Palette ──────────────────────────────────────────────────────────
  static const bg         = Color(0xFF0E1014);
  static const surface    = Color(0xFF161A20);
  static const surfaceHi  = Color(0xFF1E232C);
  static const line       = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const lineStr    = Color(0x1AFFFFFF); // rgba(255,255,255,0.10)
  static const text       = Color(0xFFEEF1F5);
  static const textDim    = Color(0x94EEF1F5); // 0.58 opacity
  static const textMute   = Color(0x57EEF1F5); // 0.34 opacity
  static const textFaint  = Color(0x2EEEF1F5); // 0.18 opacity
  static const accent     = Color(0xFFA8D5B7); // sage
  static const accentInk  = Color(0xFF0E1014);
  static const accentSoft = Color(0x1AA8D5B7); // 0.10 opacity
  static const danger     = Color(0xFFE89A8A);
  static const scrim      = Color(0x8C000000); // 0.55 opacity

  // ── 8dp spacing scale ────────────────────────────────────────────────
  static const double xs  = 4;
  static const double s   = 8;
  static const double m   = 16;
  static const double l   = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  // ── Typography helpers ───────────────────────────────────────────────
  static TextStyle ui(double size, FontWeight weight, Color color, {double ls = 0}) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: color, letterSpacing: ls);

  static TextStyle mono(double size, FontWeight weight, Color color, {double ls = 0}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color, letterSpacing: ls);
}
