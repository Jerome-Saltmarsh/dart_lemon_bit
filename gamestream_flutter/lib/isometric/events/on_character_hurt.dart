import 'dart:math';

import 'package:bleed_common/character_type.dart';
import 'package:gamestream_flutter/audio_engine.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:lemon_math/library.dart';

void onGameEventCharacterHurt(int type, double x, double y, double z, double angle) {

  randomItem(AudioEngine.audioSingleBloodyPunches).playXYZ(x, y, z);

  AudioEngine.audioSingleHeavyPunch13.playXYZ(x, y, z);

  for (var i = 0; i < 4; i++){
    spawnParticleBlood(
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
        AudioEngine.audioSingleZombieHurt.playXYZ(x, y, z);
      } else {
        AudioEngine.audioSingleZombieHit4.playXYZ(x, y, z);
      }
      break;
    case CharacterType.Rat:
      AudioEngine.audioSingleRatSqueak.playXYZ(x, y, z);
      break;
    case CharacterType.Slime:
      AudioEngine.audioSingleBloodyPunches3.playXYZ(x, y, z);
      break;
  }
}
