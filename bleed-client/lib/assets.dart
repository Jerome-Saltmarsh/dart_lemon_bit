import 'package:flutter/material.dart';

final _Assets assets = _Assets();
final _Themes themes = _Themes();

class _Assets {
  final _Fonts fonts = _Fonts();
}

class _Fonts {
  final String pressStart2P = 'PressStart2P';
  final String slackey = 'Slackey-Regular';
  final String gugi = 'Gugi-Regular';
  final String germanioOne = 'GermaniaOne-Regular';
  final String libreBarcode39Text = 'LibreBarcode39Text-Regular';
}

class _Themes {
  final pressStart2P = ThemeData(fontFamily: assets.fonts.pressStart2P);
  final slackey = ThemeData(fontFamily: assets.fonts.slackey);
  final gugi = ThemeData(fontFamily: assets.fonts.gugi);
  final germaniaOne = ThemeData(fontFamily: assets.fonts.germanioOne);
  final libreBarcode39Text = ThemeData(fontFamily: assets.fonts.libreBarcode39Text);
}