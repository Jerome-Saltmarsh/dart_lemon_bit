import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/render/enums/Hue.dart';
import 'package:bleed_client/state/particleSettings.dart';
import 'package:lemon_math/give_or_take.dart';
import 'package:lemon_math/randomItem.dart';

void emitPixel(Particle particle) {
  particle.active = true;
  particle.type = ParticleType.Pixel;
  particle.duration = particleSettings.mystDuration;
  particle.z = 0.25;
  particle.weight = 0;
  particle.scale = 1;
  particle.scaleV = 0;
  particle.rotation = 0;
  particle.rotationV = 0;
  // particle.xv = randomBetween(0, -pi * 0.1);
  // particle.yv = randomBetween(0, pi * 0.1);
  particle.xv = giveOrTake(pi) * 0.1;
  particle.yv = giveOrTake(pi) * 0.1;
  particle.zv = 0.01;
  particle.airFriction = 0.98;
  particle.hue = randomItem(hues);
}
