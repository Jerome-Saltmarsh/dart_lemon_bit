import 'package:flutter/material.dart';

final _Assets assets = _Assets();
final _Themes themes = _Themes();

class _Assets {
  final _Fonts fonts = _Fonts();
}

class _Fonts {
  final String pressStart2P = 'PressStart2P';
}

class _Themes {
  final pressStart2P = ThemeData(fontFamily: assets.fonts.pressStart2P);
}