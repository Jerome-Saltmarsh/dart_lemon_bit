import 'package:amulet_flutter/gamestream/isometric/components/isometric_images.dart';
import 'package:amulet_flutter/isometric/classes/projectile.dart';
import 'package:amulet_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:amulet_engine/packages/common.dart';
import 'package:amulet_engine/packages/lemon_math.dart';

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
      case ProjectileType.Orb:
        break;
      case ProjectileType.Fireball:
        break;
      case ProjectileType.Bullet:
        renderBullet(dstX, dstY, angle);
        break;
      case ProjectileType.Wave:
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
      case ProjectileType.Rocket:
        engine.renderSpriteRotated(
          image: images.atlas_consumables,
          srcX: 201,
          srcY: 109,
          srcWidth: 16,
          srcHeight: 7,
          dstX: projectile.renderX,
          dstY: projectile.renderY,
          rotation: projectile.angle - piQuarter + piHalf,
          scale: 1,
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

  void renderBullet(double x, double y, double rotation) {
    engine.renderSpriteRotated(
      image: images.atlas_gameobjects,
      srcX: 87,
      srcY: 48,
      srcWidth: 2,
      srcHeight: 32,
      dstX: x,
      dstY: y,
      rotation: rotation - piQuarter,
      scale: 1,
      anchorX: 0.5,
      anchorY: 0.5,
    );
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
}

