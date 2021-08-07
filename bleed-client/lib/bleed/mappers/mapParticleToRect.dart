
import 'dart:ui';

import 'package:flutter_game_engine/bleed/classes/Particle.dart';

import 'mapParticleTypeToRect.dart';

Rect mapParticleToRect(Particle particle){
  return mapParticleTypeToRect(particle.type);
}