import 'dart:math';

import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game.dart';
import 'package:lemon_math/library.dart';

void onGameEventCharacterHurt(int type, double x, double y, double z, double angle) {

  randomItem(GameAudio.audioSingleBloodyPunches).playXYZ(x, y, z);

  GameAudio.audioSingleHeavyPunch13.playXYZ(x, y, z);

  for (var i = 0; i < 4; i++){
    Game.spawnParticleBlood(
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
        GameAudio.audioSingleZombieHurt.playXYZ(x, y, z);
      } else {
        GameAudio.audioSingleZombieHit4.playXYZ(x, y, z);
      }
      break;
    case CharacterType.Rat:
      GameAudio.audioSingleRatSqueak.playXYZ(x, y, z);
      break;
    case CharacterType.Slime:
      GameAudio.audioSingleBloodyPunches3.playXYZ(x, y, z);
      break;
  }
}
