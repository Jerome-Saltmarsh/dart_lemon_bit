
import 'package:bleed_client/classes/Particle.dart';
import 'package:flutter/cupertino.dart';

import '../draw.dart';

RSTransform mapParticleToRSTransform(Particle particle){
  return rsTransform(x: particle.x, y: particle.y + particle.z, anchorX: 32, anchorY: 32, scale: particle.scale);
}