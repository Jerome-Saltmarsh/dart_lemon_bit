
import 'dart:math';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/constants/pi2.dart';
import 'package:bleed_client/common/functions/giveOrTake.dart';
import 'package:bleed_client/common/functions/randomBetween.dart';
import 'package:bleed_client/enums/ParticleType.dart';

final double _maxVelocity = 0.5;

void emitMyst(Particle particle){
  particle.type = ParticleType.Myst;
  particle.duration = randomBetween(500, 750).toInt();
  particle.z = 0.25;
  particle.weight = 0;
  particle.scale = 1;
  particle.scaleV = 0;
  particle.rotation = 0;
  particle.rotationV = 0;
  particle.bounciness = 0;
  particle.xv = giveOrTake(pi * _maxVelocity);
  particle.yv = giveOrTake(pi * _maxVelocity);
  particle.zv = 0.0;
}