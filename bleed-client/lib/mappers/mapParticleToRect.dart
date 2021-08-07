
import 'dart:ui';

import 'package:bleed_client/classes/Particle.dart';

import 'mapParticleTypeToRect.dart';

Rect mapParticleToRect(Particle particle){
  return mapParticleTypeToRect(particle.type);
}