import 'package:flutter/material.dart';

class Fonts {
  static final Jetbrains = 'JetBrainsMono-Regular';
  static final LibreBarcode39Text = 'LibreBarcode39Text-Regular';
}

class Themes {
  static final libreBarcode39Text = ThemeData(fontFamily: Fonts.LibreBarcode39Text);
  static final jetbrains = ThemeData(fontFamily: Fonts.Jetbrains);
}