import 'dart:typed_data';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';

Float32List mapParticleToDst(Particle particle){
  return mapDst(
    scale: (1 + (particle.z * 0.4)) * particle.scale,
    rotation: particle.rotation,
    x: particle.x,
    y: particle.y - (particle.z * 20)
  );
}