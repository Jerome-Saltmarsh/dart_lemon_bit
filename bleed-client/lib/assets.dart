import 'package:flutter/material.dart';

final _Assets assets = _Assets();
final _Themes themes = _Themes();

class _Assets {
  final _Fonts fonts = _Fonts();
}

class _Fonts {
  final String pressStart2P = 'PressStart2P';
  final String concertOne = 'ConcertOne-Regular';
}

class _Themes {
  final pressStart2P = ThemeData(fontFamily: assets.fonts.pressStart2P);
  final concertOne = ThemeData(fontFamily: assets.fonts.concertOne);
}