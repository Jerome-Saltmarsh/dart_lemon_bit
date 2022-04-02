
import 'package:bleed_common/enums/Direction.dart';
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

final _particles = atlas.particles;
final _isometricState = isometric.state;

const _orbRubyX = 2306.0;
const _orbRubyY = 0.0;

final _shellX = _particles.shell.x;
final _shellY = _particles.shell.y;

const _zombieHeadX = 4030.0;

void mapParticleToSrc(Particle particle){
  final shade = _isometricState.getShadeAtPosition(particle.x, particle.y);

  switch(particle.type) {
    case ParticleType.Blood:
      engine.mapSrc8(
          x: 89.0,
          y: 25.0 - (shade * 8),
      );
      return;

    case ParticleType.Orb_Ruby:
      engine.mapSrc(x: _orbRubyX, y: _orbRubyY, width: 24, height: 24);
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
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _particles.zombieLeg.x + (direction * 64);
      final y = _particles.zombieLeg.y + shade * 64;
      engine.mapSrc(x: x, y: y, width: 64, height: 64);
      return;

    case ParticleType.Arm:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _particles.zombieArm.x + (direction * 64);
      final y = _particles.zombieArm.y + shade * 64;
      engine.mapSrc64(x: x, y: y);
      return;

    case ParticleType.Organ:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _particles.zombieTorso.x + (direction * 64);
      final y = _particles.zombieTorso.y + shade * 64;
      engine.mapSrc(x: x, y: y, width: 64, height: 64);
      return;

    case ParticleType.Shell:
      final direction = convertAngleToDirectionInt(particle.rotation);
      assert(direction >= 0 && direction <= 8);
      final x = _shellX + (direction * 32);
      final y = _shellY + shade * 32;
      engine.mapSrc(x: x, y: y, width: 32, height: 32);
      return;

    case ParticleType.Human_Head:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _zombieHeadX + (direction * 64);
      final y = shade * 64.0;
      engine.mapSrc64(x: x, y: y);
      return;

    case ParticleType.Zombie_Head:
      engine.mapSrc64(
          x: 4030 + (convertAngleToDirectionInt(particle.rotation) * 64),
          y: shade * 64
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

    default:
      throw Exception("Could not map particle '${particle.type.name}' to src");
  }
}

int _mapMystDurationToIndex(int duration){
  if (duration > _a){
    return _mystIndex02;
  }
  if (duration > _b){
    return _mystIndex05;
  }
  if (duration > _c){
    return _mystIndex10;
  }
  if (duration > _d){
    return _mystIndex20;
  }
  if (duration > _d){
    return _mystIndex30;
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