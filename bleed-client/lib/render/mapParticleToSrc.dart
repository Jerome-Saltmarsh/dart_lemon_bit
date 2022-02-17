
import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/modules/isometric/atlas.dart';
import 'package:bleed_client/modules/isometric/enums.dart';
import 'package:bleed_client/modules/modules.dart';
import 'package:lemon_engine/engine.dart';

const  mystDuration = 700;

final int _a = mystDuration - 25;
final int _b = mystDuration - 50;
final int _c = mystDuration - 75;
final int _d = mystDuration - 100;
final int _e = mystDuration - 150;
final int _f = mystDuration - 200;

const _mystIndex02 = 0;
const _mystIndex05 = 1;
const _mystIndex10 = 2;
const _mystIndex20 = 3;
const _mystIndex30 = 4;
const _mystIndex40 = 5;
const _mystIndex50 = 6;
const _particleSize = 64.0;
const pixelSize = 6.0;

const _size8 = 8.0;
const _size32 = 64.0;
const _size64 = 64.0;

final _particles = atlas.particles;

void mapParticleToSrc(Particle particle){
  final shade = isometric.state.getShadeAtPosition(particle.x, particle.y);

  switch(particle.type) {
    case ParticleType.Pixel:
      final x = atlas.shades.x + (particle.hue * 8);
      final y = atlas.shades.y + (3 * 8);
      engine.mapSrc(x: x, y: y, width: pixelSize, height: pixelSize);
      return;

    case ParticleType.Smoke:
      engine.mapSrc(x: atlas.circle.x, y: atlas.circle.y);
      return;

    case ParticleType.Leg:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _particles.zombieLeg.x + (direction * _size64);
      final y = _particles.zombieLeg.y + shade * _size64;
      engine.mapSrc(x: x, y: y, width: _size64, height: _size64);
      return;

    case ParticleType.Arm:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _particles.zombieArm.x + (direction * _size64);
      final y = _particles.zombieArm.y + shade * _size64;
      engine.mapSrc(x: x, y: y);
      return;

    case ParticleType.Organ:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _particles.zombieTorso.x + (direction * _size64);
      final y = _particles.zombieTorso.y + shade * _size64;
      engine.mapSrc(x: x, y: y, width: _size64, height: _size64);
      return;

    case ParticleType.Shell:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = _particles.shell.x + (direction * _size32);
      final y = _particles.shell.y + shade * _size32;
      engine.mapSrc(x: x, y: y, width: _size32, height: _size32);
      return;

    case ParticleType.Blood:
      final x = atlas.blood.x;
      final y = atlas.blood.y - (shade * _size8);
      engine.mapSrc(x: x, y: y, width: _size8, height: _size8);
      return;

    case ParticleType.Human_Head:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = atlas.particles.shell.x + (direction * _size64);
      final y = atlas.particles.shell.y + shade * _size64;
      engine.mapSrc(x: x, y: y, width: _size64, height: _size64);
      return;

    case ParticleType.Zombie_Head:
      final direction = convertAngleToDirectionInt(particle.rotation);
      final x = atlas.particles.zombieHead.x + (direction * _size64);
      final y = atlas.particles.zombieHead.y + shade * _size64;
      engine.mapSrc(x: x, y: y, width: _size64, height: _size64);
      return;

    case ParticleType.Myst:
      final index = _mapMystDurationToIndex(particle.duration);
      final x = atlas.myst.x;
      final y = atlas.myst.y + (index * _particleSize);
      engine.mapSrc(x: x, y: y, width: _size64, height: _size64);
      break;

    case ParticleType.FireYellow:
      final x = atlas.particles.flame.x;
      final y = atlas.particles.flame.y + ((core.state.timeline.frame % 4) * 24);
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