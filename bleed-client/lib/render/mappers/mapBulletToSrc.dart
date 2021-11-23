

import 'dart:typed_data';

import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/common/enums/Shade.dart';
import 'package:bleed_client/getters/getShading.dart';
import 'package:bleed_client/render/constants/atlas.dart';

final Float32List _src = Float32List(4);

Float32List mapProjectileToSrc(Projectile projectile) {
  switch(projectile.type){
    case ProjectileType.Bullet:
      Shade shade = getShadeAtPosition(projectile.x, projectile.y);
      _src[0] = atlas.particles.shell.x + (projectile.direction.index * 32.0);
      _src[1] = atlas.particles.shell.y + shade.index * 32.0;
      _src[2] = _src[0] + 32;
      _src[3] = _src[1] + 32;
      return _src;
    case ProjectileType.Fireball:
      throw Exception();
  }
  throw Exception();
}
