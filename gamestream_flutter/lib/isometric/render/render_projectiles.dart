import 'dart:math';

import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';

void renderProjectile(Projectile value) {
  switch (value.type) {
    case ProjectileType.Arrow:
      return renderArrow(value.renderX, value.renderY, value.angle);
    case ProjectileType.Orb:
      return renderOrb(value.renderX, value.renderY);
    case ProjectileType.Fireball:
      return renderFireball(value.renderX, value.renderY, value.angle);
    case ProjectileType.Bullet:
      return renderFireball(value.renderX, value.renderY, value.angle);
    default:
      return;
  }
}

void renderFireball(double x, double y, double rotation) {
  render(
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
  render(
      dstX: x,
      dstY: y + 10,
      srcX: 2172,
      srcY: 0,
      srcWidth: 13,
      srcHeight: 47,
      rotation: angle + piQuarter,
      scale: 0.5
  );
  render(
      dstX: x,
      dstY: y,
      srcX: 2182,
      srcY: 0,
      srcWidth: 13,
      srcHeight: 47,
      rotation: angle + piQuarter,
      scale: 0.5
  );
}

void renderOrb(double x, double y) {
  render(
      dstX: x,
      dstY: y,
      srcX: 417,
      srcY: 26,
      srcWidth: 8,
      srcHeight: 8,
      scale: 1.5
  );
}
