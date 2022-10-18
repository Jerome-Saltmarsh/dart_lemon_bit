import 'package:gamestream_flutter/game.dart';
import 'package:lemon_math/library.dart';

void spawnBubbles(double x, double y, double z){
  for (var i = 0; i < 15; i++) {
    Game.spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
  }
}