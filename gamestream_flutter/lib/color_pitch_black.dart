
import 'package:flutter/cupertino.dart';

final colorPitchBlack = Color.fromRGBO(37, 32, 48, 1.0);

final colors2 = <Color> [
  colorPitchBlack.withOpacity(0), // very bright
  colorPitchBlack.withOpacity(0.35), // bright
  colorPitchBlack.withOpacity(0.65), // medium
  colorPitchBlack.withOpacity(0.85),  // dark
  colorPitchBlack.withOpacity(0.95), // very dark
  colorPitchBlack.withOpacity(1.0), // pitchBlack
];

final colorShades = <int> [
  colorPitchBlack.withOpacity(0).value, // very bright
  colorPitchBlack.withOpacity(0.35).value, // bright
  colorPitchBlack.withOpacity(0.65).value, // medium
  colorPitchBlack.withOpacity(0.85).value,  // dark
  colorPitchBlack.withOpacity(0.95).value, // very dark
  colorPitchBlack.withOpacity(1.0).value, // pitchBlack
];