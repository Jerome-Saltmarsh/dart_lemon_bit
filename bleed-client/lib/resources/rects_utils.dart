
import 'dart:ui';

Rect getFrameLoop(List<Rect> frames, int frame) {
  int actualFrame = frame ~/ 5;
  return frames[actualFrame % frames.length]; // TODO Calling frames.length is expensive
}

Rect getFrame(List<Rect> frames, int frame) {
  int actualFrame = frame ~/ 5;
  if (actualFrame >= frames.length) {
    return frames.last;
  }
  return frames[actualFrame];
}

Rect rect({double frameWidth, double frameHeight, int index}) {
  return Rect.fromLTWH(index * frameWidth, 0.0, frameWidth, frameHeight);
}
