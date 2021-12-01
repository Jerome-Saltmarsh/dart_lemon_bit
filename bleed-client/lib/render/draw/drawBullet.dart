import 'dart:math';
import 'dart:typed_data';

import 'package:bleed_client/classes/Projectile.dart';
import 'package:bleed_client/common/enums/Direction.dart';
import 'package:bleed_client/common/enums/ProjectileType.dart';
import 'package:bleed_client/getters/inDarkness.dart';
import 'package:bleed_client/images.dart';
import 'package:bleed_client/mappers/mapDirectionToAngle.dart';
import 'package:bleed_client/rects.dart';
import 'package:bleed_client/render/constants/atlas.dart';
import 'package:bleed_client/render/draw/drawAtlas.dart';
import 'package:bleed_client/render/mappers/mapBulletToSrc.dart';
import 'package:bleed_client/render/mappers/mapDst.dart';
import 'package:bleed_client/utils.dart';
import 'package:flutter/material.dart';
import 'package:lemon_engine/state/canvas.dart';
import 'package:lemon_engine/state/paint.dart';
import 'package:lemon_math/piHalf.dart';
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
    case ProjectileType.Arrow:
      drawArrow(projectile.x, projectile.y, convertDirectionToAngle(projectile.direction));
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
  // TODO use atlas instead
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

Rect _rectArrow = Rect.fromLTWH(atlas.arrow.x, atlas.arrow.y, 18, 51);

void drawArrow(double x, double y, double angle){
  RSTransform rsTransform = RSTransform.fromComponents(
      rotation: angle,
      scale: 0.5,
      anchorX: 25,
      anchorY: 9,
      translateX: x,
      translateY: y
  );
  globalCanvas.drawAtlas(
      images.atlas,
      [rsTransform],
      [_rectArrow],
      null,
      null,
      null,
      paint
  );
}
