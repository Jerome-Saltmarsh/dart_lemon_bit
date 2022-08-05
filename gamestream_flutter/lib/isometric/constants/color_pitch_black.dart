
import 'package:flutter/cupertino.dart';

final colorPitchBlack = Color.fromRGBO(37, 32, 48, 1.0);

final colorShadesColors = <Color> [
  colorPitchBlack.withOpacity(0), // very bright
  colorPitchBlack.withOpacity(0.15), // bright
  colorPitchBlack.withOpacity(0.3), // medium
  colorPitchBlack.withOpacity(0.45),  // dark
  colorPitchBlack.withOpacity(0.6), // very dark
  colorPitchBlack.withOpacity(0.75), // pitchBlack
  colorPitchBlack.withOpacity(0.9), // pitchBlack
  colorPitchBlack.withOpacity(1.0), // pitchBlack
];

final colorShades = colorShadesColors.map((color) => color.value).toList();
