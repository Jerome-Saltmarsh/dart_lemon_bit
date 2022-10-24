import 'dart:math';

import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/isometric/spawn/spawn_bubbles.dart';
import 'package:gamestream_flutter/isometric/spawn/spawn_purple_fire_explosion.dart';
import 'package:lemon_math/library.dart';

void onGameEventCharacterDeath(int type, double x, double y, double z, double angle) {
  spawnPurpleFireExplosion(x, y, z);
  spawnBubbles(x, y, z);

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
      return onCharacterDeathZombie(type, x, y, z, angle);
  }
}

void onCharacterDeathZombie(int type, double x, double y, double z, double angle){
  GameState.spawnParticleAnimation(
      type: randomItem(
          const [
            ParticleType.Character_Animation_Death_Zombie_1,
            ParticleType.Character_Animation_Death_Zombie_2,
            ParticleType.Character_Animation_Death_Zombie_3,
          ]
      ),
      x: x,
      y: y,
      z: z,
      angle: angle,
  );
  angle += pi;

  final zPos = z + tileSizeHalf;
  GameState.spawnParticleHeadZombie(x: x, y: y, z: zPos, angle: angle, speed: 4.0);
  // spawnParticleArm(
  //     x: x,
  //     y: y,
  //     z: zPos,
  //     angle: angle + giveOrTake(0.5),
  //     speed: 4.0 + giveOrTake(0.5));
  GameState.spawnParticleArm(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5));
  // spawnParticleLegZombie(
  //     x: x,
  //     y: y,
  //     z: zPos,
  //     angle: angle + giveOrTake(0.5),
  //     speed: 4.0 + giveOrTake(0.5));
  GameState.spawnParticleLegZombie(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5));
  GameState.spawnParticleOrgan(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5),
      zv: 0.1);

  randomItem(GameAudio.zombie_deaths).playXYZ(x, y, z);
}