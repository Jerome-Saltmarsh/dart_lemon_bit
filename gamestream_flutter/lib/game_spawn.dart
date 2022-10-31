
import 'library.dart';

class GameSpawn {
  static void spawnBubbles(double x, double y, double z){
    for (var i = 0; i < 5; i++) {
      GameState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: Engine.randomAngle());
    }
  }

  static void spawnPurpleFireExplosion(double x, double y, double z){
    GameAudio.magical_impact_28.playXYZ(x, y, z);
    for (var i = 0; i < 5; i++) {
      GameState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: Engine.randomAngle());
      GameState.spawnParticleFirePurple(x: x + Engine.randomGiveOrTake(5), y: y + Engine.randomGiveOrTake(5), z: z, speed: 1, angle: Engine.randomAngle());
    }
    GameState.spawnParticleLightEmission(x: x, y: y, z: z);
  }
}