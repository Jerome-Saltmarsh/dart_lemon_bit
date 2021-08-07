

import 'package:flutter_game_engine/bleed/functions/spawnBulletHole.dart';
import 'package:flutter_game_engine/bleed/maths.dart';
import 'package:flutter_game_engine/bleed/utils.dart';

import 'audio.dart';
import 'classes/SpriteAnimation.dart';
import 'spawners/spawnSmoke.dart';
import 'images.dart';
import 'state.dart';

void spawnExplosion(double x, double y){
  print("spawnExplosion()");
  playAudioExplosion();
  animations.add(SpriteAnimation(spritesExplosion, x.toDouble(), y.toDouble(), scale: 0.5)
  );
  spawnBulletHole(x, y);
  repeat((){
    spawnSmoke(x, y, 0, xv: giveOrTake(0.1), yv: giveOrTake(0.1));
  }, 15, 120);
}

