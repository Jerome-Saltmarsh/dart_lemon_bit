import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapDirectionToAngle.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/draw/drawParticle.dart';
import 'package:bleed_client/render/mappers/mapBulletToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/render/mappers/mapParticleToSrc.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/randomItem.dart';

const _scale = 0.33;
const _size = 32;
const renderSizeHalf = _scale * _size * 0.5;

void drawProjectile(Projectile projectile){
  switch(projectile.type){
    case ProjectileType.Bullet:
      if (inDarkness(projectile.x, projectile.y)) return;
      drawAtlas(mapDst(x: projectile.x - renderSizeHalf, y: projectile.y - renderSizeHalf, scale: 0.25), mapProjectileToSrc(projectile));
      break;
    case ProjectileType.Fireball:
      drawFireball(projectile.x, projectile.y, projectile.direction);
      break;
  }
}


void drawFireball(double x, double y, Direction direction){
  double angle = mapDirectionToAngle[direction];
  RSTransform rsTransform = RSTransform.fromComponents(
      rotation: angle,
      scale: 1,
      anchorX: 16,
      anchorY: 16,
      translateX: x,
      translateY: y
  );
  globalCanvas.drawAtlas(
      images.fireball,
      [rsTransform],
      [randomItem(srcRects.fireballs)],
      null,
      null,
      null,
      paint
  );
}
