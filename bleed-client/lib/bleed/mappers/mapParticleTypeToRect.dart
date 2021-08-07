import 'dart:ui';
import 'package:flutter_game_engine/bleed/enums/ParticleType.dart';
import '../rects.dart';

Rect mapParticleTypeToRect(ParticleType particleType){
  switch(particleType){
    case ParticleType.Smoke:
      return rectParticleSmoke;
    case ParticleType.Blood:
      return rectParticleBlood;
    case ParticleType.Head:
      return rectParticleHead;
    case ParticleType.Arm:
      return rectParticleArm;
    case ParticleType.Organ:
      return rectParticleOrgan;
    case ParticleType.Shell:
      return rectParticleShell;
    default:
      throw Exception("rect could not be found for particle $particleType");
  }
}
