
import 'package:bleed_common/Direction.dart';
import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/classes/Particle.dart';
import 'package:gamestream_flutter/modules/isometric/atlas.dart';
import 'package:gamestream_flutter/modules/isometric/enums.dart';
import 'package:gamestream_flutter/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

const mystDuration = 700;

const _a = mystDuration - 25;
const _b = mystDuration - 50;
const _c = mystDuration - 75;
const _d = mystDuration - 100;
const _e = mystDuration - 150;
const _f = mystDuration - 200;

const _mystIndex02 = 0;
const _mystIndex05 = 1;
const _mystIndex10 = 2;
const _mystIndex20 = 3;
const _mystIndex30 = 4;
const _mystIndex40 = 5;
const _mystIndex50 = 6;
const pixelSize = 6.0;

void mapParticleToSrc(Particle particle){
  final shade = isometric.getShadeAtPosition(particle.x, particle.y);

  switch(particle.type) {
    case ParticleType.Blood:
      engine.mapSrc8(
          x: 89.0,
          y: 25.0 - (shade * 8),
      );
      return;

    case ParticleType.Orb_Ruby:
      engine.mapSrc(x: 2306.0, y: 0, width: 24, height: 24);
      return;

    case ParticleType.Pixel:
      final x = atlas.shades.x + (particle.hue * 8);
      final y = atlas.shades.y + 24;
      engine.mapSrc(x: x, y: y, width: pixelSize, height: pixelSize);
      return;

    case ParticleType.Smoke:
      engine.mapSrc64(x: atlas.circle.x, y: atlas.circle.y);
      return;

    case ParticleType.Leg:
      engine.mapSrc64(
          x: 2491 + (convertAngleToDirection(particle.rotation) * 64),
          y:  shade * 64
      );
      return;

    case ParticleType.Arm:
      engine.mapSrc64(
          x: 3004 + (convertAngleToDirection(particle.rotation) * 64),
          y: shade * 64,
      );
      return;

    case ParticleType.Organ:
      engine.mapSrc64(
          x: 3517 + (convertAngleToDirection(particle.rotation) * 64),
          y: shade * 64
      );
      return;

    case ParticleType.Shell:
      engine.mapSrc32(
          x: 1008 + (convertAngleToDirection(particle.rotation) * 32),
          y: shade * 32
      );
      return;

    case ParticleType.Zombie_Head:
      engine.mapSrc64(
          x: 4030 + (convertAngleToDirection(particle.rotation) * 64),
          y: shade * 64
      );
      return;

    case ParticleType.Pot_Shard:
      engine.mapSrcSquare(
          x: 6097,
          y: shade * 16,
          size: 16,
      );
      return;

    case ParticleType.Myst:
      engine.mapSrc64(
          x: 5488,
          y: _mapMystDurationToIndex(particle.duration) * 64.0,
      );
      break;

    case ParticleType.FireYellow:
      final x = atlas.particles.flame.x;
      final y = atlas.particles.flame.y + ((engine.animationFrame) * 24);
      engine.mapSrc(x: x, y: y, width: 25, height: 24);
      return;


    case ParticleType.Shrapnel:
      final x = atlas.particles.circleBlackSmall.x;
      final y = atlas.particles.circleBlackSmall.y;
      engine.mapSrc(x: x, y: y, width: 7, height: 7);
      return;

    case ParticleType.Rock:
      switch (shade) {
        case Shade.Bright:
          return engine.mapSrc(x: 49, y: 25, width: 7, height: 7);
        case Shade.Medium:
          return engine.mapSrc(x: 41, y: 25, width: 7, height: 7);
        case Shade.Dark:
          return engine.mapSrc(x: 9, y: 25, width: 7, height: 7);
        case Shade.Very_Dark:
          return engine.mapSrc(x: 1, y: 25, width: 7, height: 7);
      }
      return;

    case ParticleType.Tree_Shard:
      switch (shade) {
        case Shade.Bright:
          return engine.mapSrc(x: 281, y: 25, width: 7, height: 7);
        case Shade.Medium:
          return engine.mapSrc(x: 289, y: 17, width: 7, height: 7);
        case Shade.Dark:
          return engine.mapSrc(x: 289, y: 9, width: 7, height: 7);
        case Shade.Very_Dark:
          return engine.mapSrc(x: 289, y: 1 , width: 7, height: 7);
      }

      return;

    default:
      throw Exception("Could not map particle '${particle.type}' to src");
  }
}

int _mapMystDurationToIndex(int duration){
  if (duration > _a){
    return 0;
  }
  if (duration > _b){
    return 1;
  }
  if (duration > _c){
    return 2;
  }
  if (duration > _d){
    return 3;
  }
  if (duration > _d){
    return 4;
  }
  if (duration > _e){
    return _mystIndex40;
  }
  if (duration > _f){
    return _mystIndex50;
  }
  if (duration > 150) {
    return _mystIndex40;
  }
  if (duration > 125) {
    return _mystIndex30;
  }
  if (duration > 100) {
    return _mystIndex20;
  }
  if (duration > 75) {
    return _mystIndex10;
  }
  if (duration > 50) {
    return _mystIndex05;
  }
  return _mystIndex02;
}