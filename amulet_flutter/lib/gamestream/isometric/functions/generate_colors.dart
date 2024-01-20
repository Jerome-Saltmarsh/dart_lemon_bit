
import 'package:flutter/material.dart';

List<Color> generateColorInterpolation4({
  required int length,
  required Color colorA,
  required Color colorB,
  required Color colorC,
  required Color colorD,
}){
  return List.generate(length, (index) {

    final indexThird = (length * 0.33).toInt();
    final indexTwoThirds = (length * 0.66).toInt();

    if (index < indexThird){
      return (Color.lerp(colorA, colorB, index / indexThird) ?? (throw Exception()));
    }
    if (index < indexTwoThirds){
      final total = length - indexTwoThirds;
      final i = index - indexThird;
      return (Color.lerp(colorB, colorC, i / total) ?? (throw Exception()));
    }

    final total = length - indexTwoThirds;
    final i = index - indexTwoThirds;
    return (Color.lerp(colorC, colorD, i / total) ?? (throw Exception()));
  });
}