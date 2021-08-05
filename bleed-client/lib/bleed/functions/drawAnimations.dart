
import '../classes.dart';
import '../state.dart';
import 'drawSpriteAnimation.dart';

void drawAnimations() {
  for (int i = 0; i < animations.length; i++) {
    SpriteAnimation animation = animations[i];
    drawSpriteAnimation(animation);
    if (animation.finished) {
      animations.removeAt(i);
      i--;
      print("animation finished");
    }
  }
}