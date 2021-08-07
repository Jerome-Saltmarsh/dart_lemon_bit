
import 'package:flutter/cupertino.dart';
import 'package:flutter_game_engine/bleed/classes/Particle.dart';

import '../draw.dart';

RSTransform mapParticleToRSTransform(Particle particle){
  return rsTransform(x: particle.x, y: particle.y + particle.z, anchorX: 32, anchorY: 32, scale: particle.scale);
}