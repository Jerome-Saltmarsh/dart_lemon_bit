import 'dart:ui';

import 'SpriteSheet.dart';

class SpriteAnimation {
  SpriteSheet sprite;
  int currentFrame = 0;
  double x;
  double y;
  double scale;

  Rect get rect => sprite.getRect(currentFrame);
  bool get finished => currentFrame >= sprite.frames;

  SpriteAnimation(this.sprite, this.x, this.y, {this.scale = 1.0});

  void nextFrame(){
    currentFrame++;
  }
}