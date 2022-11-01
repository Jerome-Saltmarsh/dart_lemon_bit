import 'dart:math';

import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/library.dart';


void renderProjectile(Projectile value) {
  switch (value.type) {
    case ProjectileType.Arrow:
      // renderPixelRed(value.renderX, value.renderY);
      return RenderProjectiles.renderArrow(value.renderX, value.renderY, value.angle);
    case ProjectileType.Orb:
      return renderOrb(value.renderX, value.renderY);
    case ProjectileType.Fireball:
      // renderPixelRed(value.renderX, value.renderY);
      // return renderFireball(value.renderX, value.renderY, value.angle - piQuarter);
      break;
    case ProjectileType.Bullet:
      // return renderRotated(
      //     dstX: value.renderX,
      //     dstY: value.renderY,
      //     srcX: 2576,
      //     srcY: (Engine.paintFrame % 6) * 64,
      //     srcWidth: 64,
      //     srcHeight:64,
      //     rotation: value.angle + pi - piQuarter,
      // );
      break;
    case ProjectileType.Wave:
      // render(dstX: value.renderX, dstY: value.renderY, srcX: 144, srcY: 0, srcWidth: 8, srcHeight: 8);
      // return renderRotated(
      //   dstX: value.renderX,
      //   dstY: value.renderY,
      //   srcX: 1332,
      //   srcY: (animationFrame % 3) * 32,
      //   srcWidth: 32,
      //   srcHeight: 32,
      //   rotation: value.angle - piQuarter,
      //   color: Game.getV3NodeBelowShade(value),
      // );
      break;
    default:
      return;
  }
}
const piQuarter = pi * 0.25;

void renderPixelRed(double x, double y){
  // Engine.renderBuffer(
  //     dstX: x,
  //     dstY: y,
  //     srcX: 144, srcY: 0, srcWidth: 8, srcHeight: 8);
}

void renderFireball(double x, double y, double rotation) {
  // renderRotated(
  //   dstX: x,
  //   dstY: y,
  //   srcX: 5580,
  //   srcY: ((animationFrame) % 6) * 23,
  //   srcWidth: 18,
  //   srcHeight: 23,
  //   rotation: rotation,
  // );
}


void renderOrb(double x, double y) {
  Engine.renderSprite(
      image: GameImages.gameobjects,
      dstX: x,
      dstY: y,
      srcX: 417,
      srcY: 26,
      srcWidth: 8,
      srcHeight: 8,
      scale: 1.5
  );
}
