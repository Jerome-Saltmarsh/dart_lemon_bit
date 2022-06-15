import 'package:bleed_common/Projectile_Type.dart';
import 'package:gamestream_flutter/isometric/classes/projectile.dart';
import 'package:gamestream_flutter/isometric/state/projectiles.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';

void renderProjectiles() {
  for (var i = 0; i < totalProjectiles; i++) {
    _renderProjectile(projectiles[i]);
  }
}

void _renderProjectile(Projectile value) {
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
  // const piQuarter = pi / 4.0;
  // engine.mapSrc(x: 2182, y: 1, width: 13, height: 47);
  // engine.mapDst(
  //     x: x,
  //     y: y - 20,
  //     rotation: angle + piQuarter,
  //     anchorX: 6.5,
  //     anchorY: 30,
  //     scale: 0.5);
  // engine.renderAtlas();
  // engine.mapSrc(x: 2172, y: 1, width: 13, height: 47);
  // engine.mapDst(
  //     x: x,
  //     y: y,
  //     rotation: angle + piQuarter,
  //     anchorX: 6.5,
  //     anchorY: 30,
  //     scale: 0.5);
  // engine.renderAtlas();
}

void renderOrb(double x, double y) {
  // engine.renderCustom(
  //     dstX: x,
  //     dstY: y,
  //     srcX: 417,
  //     srcY: 26,
  //     srcWidth: 8,
  //     srcHeight: 8,
  //     scale: 1.5);
}
