
import 'dart:math';

import 'package:gamestream_flutter/isometric/classes/character.dart';

double single({
      required int frame,
      required num direction,
      required int framesPerDirection,
      double size = 64.0
}) {
  return ((direction * framesPerDirection) + (frame - 1)) * size;
}


double getSrc({
  required List<int> animation,
  required int direction,
  required int frame,
  required int framesPerDirection,
  double size = 64.0
}) {
  final animationFrame = frame % animation.length;
  final playFrame = animation[animationFrame] - 1;
  return (direction * framesPerDirection * size) + (playFrame * size);
}

double loop({
      required List<int> animation,
      required Character character,
      required int framesPerDirection,
      double size = 64.0
}) {
  final animationFrame = character.frame % animation.length;
  final frame = animation[animationFrame] - 1;
  return (character.direction * framesPerDirection * size) + (frame * size);
}

double loop4({
      required List<int> animation,
      required Character character,
      required int framesPerDirection,
      double size = 64,
}) {
  return (character.direction * framesPerDirection * size) +
      ((animation[character.frame % 4] - 1) * size);
}

double animate({
      required List<int> animation,
      required Character character,
      required int framesPerDirection,
      double size = 64.0
}) {
  final animationFrame = min(character.frame, animation.length - 1);
  final frame = animation[animationFrame] - 1;
  return (character.direction * framesPerDirection * size) + (frame * size);
}
