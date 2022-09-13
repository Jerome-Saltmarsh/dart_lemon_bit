import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:gamestream_flutter/isometric/spawn/spawn_bubbles.dart';
import 'package:gamestream_flutter/isometric/spawn/spawn_purple_fire_explosion.dart';
import 'package:lemon_math/library.dart';

void onCharacterDeath(int type, double x, double y, double z, double angle) {
  spawnPurpleFireExplosion(x, y, z);
  spawnBubbles(x, y, z);


  switch (type) {
    case CharacterType.Zombie:
      return onCharacterDeathZombie(type, x, y, z, angle);
  }
}

void onCharacterDeathZombie(int type, double x, double y, double z, double angle){

  final zPos = z + tileSizeHalf;
  spawnParticleHeadZombie(x: x, y: y, z: zPos, angle: angle, speed: 4.0);
  spawnParticleArm(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5));
  spawnParticleArm(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5));
  spawnParticleLegZombie(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5));
  spawnParticleLegZombie(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5));
  spawnParticleOrgan(
      x: x,
      y: y,
      z: zPos,
      angle: angle + giveOrTake(0.5),
      speed: 4.0 + giveOrTake(0.5),
      zv: 0.1);

  randomItem(audioSingleZombieDeaths).playXYZ(x, y, z);
}