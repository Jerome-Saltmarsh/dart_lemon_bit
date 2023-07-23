import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_projectile.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/library.dart';

class RendererProjectiles extends IsometricRenderer {

  late IsometricProjectile projectile;

  RendererProjectiles(super.scene);
  
  @override
  void renderFunction() {
    switch (projectile.type) {
      case ProjectileType.Arrow:
        renderArrow(projectile.renderX, projectile.renderY, projectile.angle);
        return;
      case ProjectileType.Orb:
        break;
      case ProjectileType.Fireball:
        break;
      case ProjectileType.Bullet:
        renderBullet(projectile.renderX, projectile.renderY, projectile.angle);
        break;
      case ProjectileType.Wave:
        break;
      case ProjectileType.Rocket:
        gamestream.engine.renderSpriteRotated(
          image: Images.atlas_items,
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
    projectile = gamestream.projectiles[index];
    order = projectile.sortOrder;
  }

  @override
  int getTotal() {
    return gamestream.totalProjectiles;
  }

  static void renderBullet(double x, double y, double rotation) {
    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_gameobjects,
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

  static void renderArrow(double x, double y, double rotation) {
    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_gameobjects,
      srcX: 49,
      srcY: 48,
      srcWidth: 9,
      srcHeight: 44,
      dstX: x,
      dstY: y + 10,
      rotation: rotation - piQuarter,
      scale: 0.7,
    );

    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_gameobjects,
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

