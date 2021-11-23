import 'dart:typed_data';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';

Map<ParticleType, double> _particleTypeSize = {
  ParticleType.Zombie_Head: 32.0,
  ParticleType.Human_Head: 32.0,
  ParticleType.Myst: 64.0,
};

Float32List mapParticleToDst(Particle particle){
  double size = _particleTypeSize[particle.type];
  double renderScale = (1 + (particle.z * 0.4)) * particle.scale;
  double sizeHalf = size * renderScale * 0.5;

  return mapDst(
    scale: renderScale,
    rotation: particle.rotation,
    x: particle.x - sizeHalf,
    y: particle.y - (particle.z * 20) - sizeHalf
  );
}