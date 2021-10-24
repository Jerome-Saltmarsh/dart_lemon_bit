import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/functions/giveOrTake.dart';
import 'package:bleed_client/common/functions/randomBetween.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/state/particleSettings.dart';

void emitMyst(Particle particle) {
  particle.type = ParticleType.Myst;
  particle.duration = particleSettings.mystDuration;
  particle.x += giveOrTake(particleSettings.mystPositionRange);
  particle.y += giveOrTake(particleSettings.mystPositionRange);
  particle.z = 0.25;
  particle.weight = 0;
  particle.scale = 1;
  particle.scaleV = 0;
  particle.rotation = 0;
  particle.rotationV = 0;
  particle.bounciness = 0;
  particle.airFriction = 1.0;
  particle.xv = giveOrTake(pi * particleSettings.mystMaxVelocity);
  particle.yv = giveOrTake(pi * particleSettings.mystMaxVelocity);
  particle.zv = 0.0;
}
