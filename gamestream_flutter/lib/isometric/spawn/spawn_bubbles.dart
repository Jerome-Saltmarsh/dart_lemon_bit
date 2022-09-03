import 'package:lemon_math/library.dart';
import 'package:gamestream_flutter/isometric/particles.dart';

void spawnBubbles(double x, double y, double z){
  for (var i = 0; i < 15; i++) {
    spawnParticleBubble(x: x, y: y, z: z, speed: 1, angle: randomAngle());
  }
}