import 'dart:typed_data';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';

const double _32 = 32.0;
const double _64 = 32.0;

final Map<ParticleType, double> _particleTypeSize = {
  ParticleType.Zombie_Head: _32,
  ParticleType.Blood: _32,
  ParticleType.Human_Head: _32,
  ParticleType.Myst: _64,
  ParticleType.Smoke: _32,
  ParticleType.Shrapnel: _32,
  ParticleType.Shell: _32,
  ParticleType.Organ: _32,
  ParticleType.FireYellow: _32,
  ParticleType.Arm: _32,
};

Float32List mapParticleToDst(Particle particle){
  double size = _particleTypeSize[particle.type];
  double renderScale = (1 + (particle.z * 0.4)) * particle.scale;
  double sizeHalf = size * renderScale * 0.5;

  return mapDst(
    scale: renderScale,
    rotation: 0,
    x: particle.x - sizeHalf,
    y: particle.y - (particle.z * 20) - sizeHalf
  );
}