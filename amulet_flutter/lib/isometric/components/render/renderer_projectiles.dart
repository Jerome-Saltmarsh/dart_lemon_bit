import 'package:amulet_common/src.dart';
import 'package:amulet_flutter/isometric/components/isometric_images.dart';
import 'package:amulet_flutter/isometric/classes/projectile.dart';
import 'package:amulet_flutter/isometric/classes/render_group.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';

class RendererProjectiles extends RenderGroup {

  late Projectile projectile;

  @override
  void renderFunction(LemonEngine engine, IsometricImages images) {
    final projectile = this.projectile;
    final dstX = projectile.renderX;
    final dstY = projectile.renderY;
    final angle = projectile.angle;

    switch (projectile.type) {
      case ProjectileType.Arrow:
        renderArrow(dstX, dstY, angle);
        return;
      case ProjectileType.Ice_Arrow:
        renderIceArrow(dstX, dstY, angle);
        return;
      case ProjectileType.Fire_Arrow:
        renderFireArrow(dstX, dstY, angle);
        renderFireball(dstX: dstX, dstY: dstY);
        return;
      case ProjectileType.Fireball:
        renderFireball(dstX: dstX, dstY: dstY);
        break;
      case ProjectileType.FrostBall:
        engine.renderSprite(
            image: images.atlas_projectiles,
            srcX: 36,
            srcY: 4,
            srcWidth: 24,
            srcHeight: 24,
            dstX: dstX,
            dstY: dstY,
        );
        break;
      default:
        return;
    }
  }

  @override
  void updateFunction() {
    projectile = scene.projectiles[index];
    order = projectile.sortOrder;
  }

  @override
  int getTotal() {
    return scene.totalProjectiles;
  }

  void renderArrow(double x, double y, double rotation) {
    engine.renderSpriteRotated(
      image: images.atlas_gameobjects,
      srcX: 49,
      srcY: 48,
      srcWidth: 9,
      srcHeight: 44,
      dstX: x,
      dstY: y + 10,
      rotation: rotation - piQuarter,
      scale: 0.7,
    );

    engine.renderSpriteRotated(
      image: images.atlas_gameobjects,
      srcX: 59,
      srcY: 48,
      srcWidth: 9,
      srcHeight: 44,
      dstX: x,
      dstY: y,
      rotation: rotation - piQuarter,
      scale: 0.7,
    );
  }

  void renderIceArrow(double x, double y, double rotation) {
    // shadow
    engine.renderSpriteRotated(
      image: images.atlas_gameobjects,
      srcX: 49,
      srcY: 48,
      srcWidth: 9,
      srcHeight: 44,
      dstX: x,
      dstY: y + 10,
      rotation: rotation - piQuarter,
      scale: 0.7,
    );

    engine.renderSpriteRotated(
      image: images.atlas_gameobjects,
      srcX: 260,
      srcY: 0,
      srcWidth: 8,
      srcHeight: 44,
      dstX: x,
      dstY: y,
      rotation: rotation - piQuarter,
      scale: 0.7,
    );
  }

  void renderFireball({
    required double dstX,
    required double dstY,
  }){
    const width = 18.0;
    const height = 23.0;
    engine.renderSpriteRotated(
      image: images.atlas_nodes,
      srcX: 1177 + (width * (animation.frameRate3 % 6)),
      srcY: 1816,
      srcWidth: width,
      srcHeight: height,
      dstX: dstX,
      dstY: dstY,
      rotation: projectile.angle - piQuarter,
    );
  }

  void renderFireArrow(double x, double y, double rotation) {
    // shadow
    engine.renderSpriteRotated(
      image: images.atlas_gameobjects,
      srcX: 49,
      srcY: 48,
      srcWidth: 9,
      srcHeight: 44,
      dstX: x,
      dstY: y + 10,
      rotation: rotation - piQuarter,
      scale: 0.7,
    );

    engine.renderSpriteRotated(
      image: images.atlas_gameobjects,
      srcX: 269,
      srcY: 0,
      srcWidth: 8,
      srcHeight: 44,
      dstX: x,
      dstY: y,
      rotation: rotation - piQuarter,
      scale: 0.7,
    );
  }
}

