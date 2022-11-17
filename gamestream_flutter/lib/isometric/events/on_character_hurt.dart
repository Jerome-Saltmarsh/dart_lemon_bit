import 'dart:math';

import 'package:gamestream_flutter/library.dart';
import 'package:lemon_math/library.dart';

void onGameEventCharacterHurt(int type, double x, double y, double z, double angle) {

  randomItem(GameAudio.bloody_punches).playXYZ(x, y, z);

  GameAudio.heavy_punch_13.playXYZ(x, y, z);

  for (var i = 0; i < 4; i++){
    GameState.spawnParticleBlood(
        x: x,
        y: y,
        z: z,
        zv: randomBetween(1.5, 2),
        angle: angle + pi + giveOrTake(piQuarter),
        speed: randomBetween(1.5, 2.5),
    );
  }

  switch (type) {
    case CharacterType.Zombie:
      if (randomBool()){
        GameAudio.zombie_hurt_1.playXYZ(x, y, z);
      } else {
        GameAudio.zombie_hurt_4.playXYZ(x, y, z);
      }
      break;
    case CharacterType.Rat:
      GameAudio.rat_squeak.playXYZ(x, y, z);
      break;
    case CharacterType.Slime:
      GameAudio.bloody_punches_3.playXYZ(x, y, z);
      break;
  }
}
