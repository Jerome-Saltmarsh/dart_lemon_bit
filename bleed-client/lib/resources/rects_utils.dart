
import 'dart:ui';

import '../keys.dart';

Rect getFrameLoop(List<Rect> frames, dynamic character) {
  int actualFrame = character[frameCount] ~/ 5;
  return frames[actualFrame % frames.length]; // TODO Calling frames.length is expensive
}

Rect getFrame(List<Rect> frames, dynamic character) {
  int actualFrame = character[frameCount] ~/ 5;
  if (actualFrame >= frames.length) {
    return frames.last;
  }
  return frames[actualFrame];
}