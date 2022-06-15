import 'dart:math';

import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:lemon_engine/engine.dart';

void renderProjectile(Projectile value) {
  switch (value.type) {
    case ProjectileType.Arrow:
      renderArrow(value.renderX, value.renderY, value.angle);
      break;
    case ProjectileType.Orb:
      renderOrb(value.renderX, value.renderY);
      break;
    case ProjectileType.Fireball:
      renderFireball(value.renderX, value.renderY, value.angle);
      break;
    case ProjectileType.Bullet:
      renderFireball(value.renderX, value.renderY, value.angle);
      break;
    default:
      return;
  }
}

void renderFireball(double x, double y, double rotation) {
  engine.renderCustom(
    dstX: x,
    dstY: y,
    srcX: 5669,
    srcY: ((x + y + (engine.frame ~/ 5) % 6) * 23),
    srcWidth: 18,
    srcHeight: 23,
    rotation: rotation,
  );
}

void renderArrow(double x, double y, double angle) {
  const piQuarter = pi / 4.0;
  engine.mapSrc(x: 2182, y: 1, width: 13, height: 47);
  engine.mapDst(
      x: x,
      y: y - 20,
      rotation: angle + piQuarter,
      anchorX: 6.5,
      anchorY: 30,
      scale: 0.5);
  engine.renderAtlas();
  engine.mapSrc(x: 2172, y: 1, width: 13, height: 47);
  engine.mapDst(
      x: x,
      y: y,
      rotation: angle + piQuarter,
      anchorX: 6.5,
      anchorY: 30,
      scale: 0.5);
  engine.renderAtlas();
}

void renderOrb(double x, double y) {
  engine.renderCustom(
      dstX: x,
      dstY: y,
      srcX: 417,
      srcY: 26,
      srcWidth: 8,
      srcHeight: 8,
      scale: 1.5);
}
