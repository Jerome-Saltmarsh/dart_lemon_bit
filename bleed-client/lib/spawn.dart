


import 'package:bleed_client/spawners/spawnShrapnel.dart';
import 'package:bleed_client/utils.dart';

import 'audio.dart';
import 'classes/SpriteAnimation.dart';
import 'functions/spawnBulletHole.dart';
import 'images.dart';
import 'maths.dart';
import 'spawners/spawnSmoke.dart';
import 'state.dart';

int get shrapnelCount => randomInt(4, 15);

void spawnExplosion(double x, double y){
  print("spawnExplosion()");
  playAudioExplosion();
  animations.add(SpriteAnimation(spritesExplosion, x.toDouble(), y.toDouble(), scale: 0.5)
  );
  spawnBulletHole(x, y);
  for(int i = 0; i < randomInt(4, 10); i++){
    spawnShrapnel(x, y);
  }
  double r = 0.2;
  repeat((){
    spawnSmoke(x, y, 0.01, xv: giveOrTake(r), yv: giveOrTake(r));
  }, 15, 120);
}

