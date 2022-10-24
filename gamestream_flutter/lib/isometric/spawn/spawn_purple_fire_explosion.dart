import 'package:gamestream_flutter/game_audio.dart';
import 'package:gamestream_flutter/game_state.dart';
import 'package:lemon_math/library.dart';

void spawnPurpleFireExplosion(double x, double y, double z){
  GameAudio.magical_impact_28.playXYZ(x, y, z);
  for (var i = 0; i < 15; i++) {
    GameState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
    GameState.spawnParticleFirePurple(x: x + giveOrTake(5), y: y + giveOrTake(5), z: z, speed: 1, angle: randomAngle());
  }
  GameState.spawnParticleLightEmission(x: x, y: y, z: z);
}