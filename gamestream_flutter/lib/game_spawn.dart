
import 'library.dart';

class GameSpawn {
  static void spawnBubbles(double x, double y, double z, {int amount = 5}){
    for (var i = 0; i < amount; i++) {
      gamestream.games.isometric.clientState.spawnParticleBubble(x: x + Engine.randomGiveOrTake(5), y: y + Engine.randomGiveOrTake(5), z: z, speed: 1, angle: Engine.randomAngle());
    }
  }

  static void spawnPurpleFireExplosion(double x, double y, double z){
    gamestream.audio.magical_impact_16.playXYZ(x, y, z, maxDistance: 600);
    for (var i = 0; i < 5; i++) {
      gamestream.games.isometric.clientState.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: Engine.randomAngle());
      gamestream.games.isometric.clientState.spawnParticleFirePurple(x: x + Engine.randomGiveOrTake(5), y: y + Engine.randomGiveOrTake(5), z: z, speed: 1, angle: Engine.randomAngle());
    }

    gamestream.games.isometric.clientState.spawnParticleLightEmission(
        x: x,
        y: y,
        z: z,
        hue: 259,
        saturation: 45,
        value: 95,
        alpha: 0,
    );
  }
}