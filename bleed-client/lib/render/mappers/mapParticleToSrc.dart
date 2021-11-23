
import 'dart:typed_data';

import 'package:bleed_client/classes/Particle.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/enums/ParticleType.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/state/particleSettings.dart';
import 'package:bleed_client/utils.dart';

final int _a = particleSettings.mystDuration - 25;
final int _b = particleSettings.mystDuration - 50;
final int _c = particleSettings.mystDuration - 75;
final int _d = particleSettings.mystDuration - 100;
final int _e = particleSettings.mystDuration - 150;
final int _f = particleSettings.mystDuration - 200;

const _mystIndex02 = 0;
const _mystIndex05 = 1;
const _mystIndex10 = 2;
const _mystIndex20 = 3;
const _mystIndex30 = 4;
const _mystIndex40 = 5;
const _mystIndex50 = 6;
const _particleSize = 64.0;

final Float32List _src = Float32List(4);

Float32List mapParticleToSrc(Particle particle){

  Shade shade = getShadeAtPosition(particle.x, particle.y);

  switch(particle.type){
    case ParticleType.Shell:
      Direction direction = convertAngleToDirection(particle.rotation);
      _src[0] = atlas.particles.shell.x + (direction.index * 32.0);
      _src[1] = atlas.particles.shell.y + shade.index * 32.0;
      _src[2] = _src[0] + 32;
      _src[3] = _src[1] + 32;
      return _src;

    case ParticleType.Blood:
      _src[0] = atlas.particles.blood.x;
      _src[1] = atlas.particles.blood.y + shade.index * 32.0;
      _src[2] = _src[0] + 32;
      _src[3] = _src[1] + 32;
      return _src;

    case ParticleType.Human_Head:
      _src[0] = atlas.particles.zombieHead.x;
      _src[1] = atlas.particles.zombieHead.y + shade.index * 32.0;
      _src[2] = _src[0] + 32;
      _src[3] = _src[1] + 32;
      return _src;

    case ParticleType.Zombie_Head:
      _src[0] = atlas.particles.zombieHead.x;
      _src[1] = atlas.particles.zombieHead.y + shade.index * 32.0;
      _src[2] = _src[0] + 32;
      _src[3] = _src[1] + 32;
      return _src;

    case ParticleType.Myst:
      int index = _mapMystDurationToIndex(particle.duration);
      _src[0] = atlas.myst.x;
      _src[1] = atlas.myst.y + (index * _particleSize);
      break;
    default:
      return _src;
  }
  _src[2] = _src[0] + _particleSize;
  _src[3] = _src[1] + _particleSize;
  return _src;
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