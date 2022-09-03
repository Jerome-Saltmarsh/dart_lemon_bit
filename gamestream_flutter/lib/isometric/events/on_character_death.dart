import 'package:bleed_common/character_type.dart';
import 'package:bleed_common/library.dart';
import 'package:bleed_common/tile_size.dart';
import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:lemon_math/library.dart';

void onCharacterDeath(int type, double x, double y, double z, double angle) {
  for (var i = 0; i < 15; i++) {
    spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
    spawnParticleFirePurple(x: x + giveOrTake(5), y: y + giveOrTake(5), z: z, speed: 1, angle: randomAngle());
  }
  switch (type){
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