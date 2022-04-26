
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:lemon_engine/engine.dart';

const zToScaleRatio = 0.4;
const zToHeightRatio = 20;

void mapParticleToDst(Particle particle){
  final sizeHalf = particle.size * 0.5;
  return engine.mapDst(
    scale: (1.0 + (particle.z * zToScaleRatio)) * particle.scale,
    rotation: particle.customRotation ? 0 : particle.rotation,
    x: particle.x,
    y: particle.y - (particle.z * zToHeightRatio),
    anchorX: sizeHalf,
    anchorY: sizeHalf,
  );
}