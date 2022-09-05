import 'package:gamestream_flutter/isometric/audio/audio_singles.dart';
import 'package:gamestream_flutter/isometric/particles.dart';
import 'package:lemon_math/library.dart';

void spawnPurpleFireExplosion(double x, double y, double z){
  audioSingleMagicalImpact28.playXYZ(x, y, z);
  for (var i = 0; i < 15; i++) {
    spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
    spawnParticleFirePurple(x: x + giveOrTake(5), y: y + giveOrTake(5), z: z, speed: 1, angle: randomAngle());
  }
}