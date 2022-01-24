
import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/constants/colours.dart';
import 'package:bleed_client/core/drawCanvas.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapDirectionToAngle.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/mappers/mapBulletToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/render/draw_circle.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';

const _scale = 0.33;
const _size = 32;
const renderSizeHalf = _scale * _size * 0.5;

void drawProjectile(Projectile projectile) {
  switch (projectile.type) {
    case ProjectileType.Bullet:
      if (inDarkness(projectile.x, projectile.y)) return;
      drawAtlas(
          dst: mapDst(
              x: projectile.x - renderSizeHalf,
              y: projectile.y - renderSizeHalf,
              scale: 0.25),
          src: mapProjectileToSrc(projectile)
      );
      break;
    case ProjectileType.Fireball:
      drawFireball(projectile.x, projectile.y, projectile.direction);
      break;
    case ProjectileType.Arrow:
      drawArrow(projectile.x, projectile.y,
          convertDirectionToAngle(projectile.direction));
      break;
    case ProjectileType.Blue_Orb:
      drawCircle(projectile.x, projectile.y, 5, colours.blue);
      break;
  }
}

void drawFireball(double x, double y, Direction direction) {
  double angle = mapDirectionToAngle[direction]!;
  RSTransform rsTransform = RSTransform.fromComponents(
      rotation: angle,
      scale: 1,
      anchorX: 16,
      anchorY: 16,
      translateX: x,
      translateY: y);

  int frame = timeline.frame % 4;

  Rect rect = Rect.fromLTWH(atlas.projectiles.fireball.x, atlas.projectiles.fireball.y + (frame * atlas.projectiles.fireball.size),
      atlas.projectiles.fireball.size, atlas.projectiles.fireball.size);

  // TODO use atlas instead
  globalCanvas.drawAtlas(images.atlas, [rsTransform],
      [rect], null, null, null, paint);
}

Rect _rectArrow = Rect.fromLTWH(atlas.arrow.x, atlas.arrow.y, 18, 51);

void drawArrow(double x, double y, double angle) {
  RSTransform rsTransform = RSTransform.fromComponents(
      rotation: angle,
      scale: 0.5,
      anchorX: 25,
      anchorY: 9,
      translateX: x,
      translateY: y);
  globalCanvas.drawAtlas(
      images.atlas, [rsTransform], [_rectArrow], null, null, null, paint);
}
