import 'dart:typed_data';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/render/functions/setDst.dart';

final Float32List _dst = Float32List(4);

Float32List mapParticleToDst(Particle particle){
  setDst(_dst,
    scale: particle.scale,
    rotation: particle.rotation,
    x: particle.x,
    y: particle.y
  );

  return _dst;
}