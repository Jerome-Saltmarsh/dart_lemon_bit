
import 'package:flutter/cupertino.dart';

final colorPitchBlack = Color.fromRGBO(37, 32, 48, 1.0);

final colorShades = <int> [
  colorPitchBlack.withOpacity(0).value, // very bright
  colorPitchBlack.withOpacity(0.2).value, // bright
  colorPitchBlack.withOpacity(0.4).value, // medium
  colorPitchBlack.withOpacity(0.6).value,  // dark
  colorPitchBlack.withOpacity(0.8).value, // very dark
  colorPitchBlack.withOpacity(1.0).value, // pitchBlack
];