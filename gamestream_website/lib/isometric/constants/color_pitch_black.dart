
import 'package:flutter/cupertino.dart';

final colorPitchBlack = Color.fromRGBO(37, 32, 48, 1.0);

final colorShadesColors = <Color> [
  colorPitchBlack.withOpacity(0), // very bright
  colorPitchBlack.withOpacity(0.4), // bright
  colorPitchBlack.withOpacity(0.6), // medium
  colorPitchBlack.withOpacity(0.7),  // dark
  colorPitchBlack.withOpacity(0.8), // very dark
  colorPitchBlack.withOpacity(0.95), // pitchBlack
  colorPitchBlack.withOpacity(1), // pitchBlack
];

final colorShades = colorShadesColors.map((color) => color.value).toList();
