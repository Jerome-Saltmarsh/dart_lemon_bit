import 'package:bleed_client/functions/spawners/spawnParticle.dart';
import 'package:bleed_client/maths.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:lemon_math/give_or_take.dart';

void spawnShotSmoke(double x, double y, double xv, double yv) {
  for (int i = 0; i < 4; i++) {
    double speed = 0.5 + giveOrTake(0.2);
    double cx = clampMagnitudeX(xv, yv, speed) + giveOrTake(0.3);
    double cy = clampMagnitudeY(xv, yv, speed) + giveOrTake(0.3);

    spawnParticle(
        type: ParticleType.Smoke,
        x: x,
        y: y,
        z: 0.3,
        xv: cx,
        yv: cy,
        zv: 0.0075,
        weight: 0.0,
        duration: 120,
        rotation: 0,
        rotationV: 0,
        scale: 0.35 + giveOrTake(0.15),
        scaleV: 0.001 + giveOrTake(0.0005));
  }
}
