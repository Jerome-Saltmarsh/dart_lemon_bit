
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:lemon_engine/engine.dart';

const double _32 = 32.0;
const double _64 = 32.0;
const zToScaleRatio = 0.4;
const zToHeightRatio = 20;
const zero = 0.0;
const half = 0.5;
const one = 1;

final Map<ParticleType, double> _particleTypeSize = {
  ParticleType.Zombie_Head: _32,
  ParticleType.Blood: _32,
  ParticleType.Human_Head: _32,
  ParticleType.Myst: _64,
  ParticleType.Smoke: _32,
  ParticleType.Shrapnel: _32,
  ParticleType.Shell: _32,
  ParticleType.Organ: 64,
  ParticleType.FireYellow: _32,
  ParticleType.Arm: 64,
  ParticleType.Leg: 64,
  ParticleType.Pixel: 8,
};

void mapParticleToDst(Particle particle){
  final size = _particleTypeSize[particle.type]!;
  final renderScale = (one + (particle.z * zToScaleRatio)) * particle.scale;
  final sizeHalf = size * half;

  return engine.mapDst(
    scale: renderScale,
    rotation: zero,
    x: particle.x,
    y: particle.y,
    anchorX: sizeHalf,
    anchorY: sizeHalf - (particle.z * zToHeightRatio)
  );
}