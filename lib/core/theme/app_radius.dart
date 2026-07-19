import 'package:flutter/material.dart';

/// Border radius system
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;

  // Presets
  static const BorderRadius button = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius textField = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
  static const BorderRadius dialog = BorderRadius.all(Radius.circular(xl));
}
