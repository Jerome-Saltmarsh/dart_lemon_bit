

import 'audio.dart';
import 'classes/SpriteAnimation.dart';
import 'images.dart';
import 'state.dart';

void spawnExplosion(double x, double y){
  print("spawnExplosion()");
  playAudioExplosion();
  animations.add(SpriteAnimation(spritesExplosion, x.toDouble(), y.toDouble(), scale: 0.5)
  );
}