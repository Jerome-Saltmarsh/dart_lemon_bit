
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:lemon_engine/engine.dart';

const double _32 = 32.0;
const double _64 = 32.0;
const zToHeightRatio = 0.4;

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
  final renderScale = (1 + (particle.z * zToHeightRatio)) * particle.scale;
  final sizeHalf = size * renderScale * 0.5;

  return engine.actions.mapDst(
    scale: renderScale,
    rotation: 0,
    x: particle.x - sizeHalf,
    y: particle.y - (particle.z * 20) - sizeHalf
  );
}