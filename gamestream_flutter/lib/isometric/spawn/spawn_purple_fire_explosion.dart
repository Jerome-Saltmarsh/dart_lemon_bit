import 'package:gamestream_flutter/game.dart';
import 'package:gamestream_flutter/game_audio.dart';
import 'package:lemon_math/library.dart';

void spawnPurpleFireExplosion(double x, double y, double z){
  GameAudio.audioSingleMagicalImpact28.playXYZ(x, y, z);
  for (var i = 0; i < 15; i++) {
    Game.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
    Game.spawnParticleFirePurple(x: x + giveOrTake(5), y: y + giveOrTake(5), z: z, speed: 1, angle: randomAngle());
  }
  Game.spawnParticleLightEmission(x: x, y: y, z: z);
}