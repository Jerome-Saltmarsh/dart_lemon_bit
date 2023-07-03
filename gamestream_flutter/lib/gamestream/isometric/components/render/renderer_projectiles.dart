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
        engine.renderSpriteRotated(
          image: Images.atlas_items,
          srcX: 201,
          srcY: 109,
          srcWidth: 16,
          srcHeight: 7,
          dstX: projectile.renderX,
          dstY: projectile.renderY,
          rotation: projectile.angle - Engine.PI_Quarter + Engine.PI_Half,
          scale: 1,
        );
        break;
      default:
        return;
    }
  }

  @override
  void updateFunction() {
    projectile = gamestream.isometric.server.projectiles[index];
    orderRowColumn = projectile.indexSum;
    orderZ = projectile.indexZ;
  }

  @override
  int getTotal() {
    return gamestream.isometric.server.totalProjectiles;
  }

  static void renderBullet(double x, double y, double rotation) {
    engine.renderSpriteRotated(
      image: Images.atlas_gameobjects,
      srcX: 87,
      srcY: 48,
      srcWidth: 2,
      srcHeight: 32,
      dstX: x,
      dstY: y,
      rotation: rotation - Engine.PI_Quarter,
      scale: 1,
      anchorX: 0.5,
      anchorY: 0.5,
    );
  }

  static void renderArrow(double x, double y, double rotation) {
    engine.renderSpriteRotated(
      image: Images.atlas_gameobjects,
      srcX: 49,
      srcY: 48,
      srcWidth: 9,
      srcHeight: 44,
      dstX: x,
      dstY: y + 10,
      rotation: rotation - Engine.PI_Quarter,
      scale: 0.7,
    );

    engine.renderSpriteRotated(
      image: Images.atlas_gameobjects,
      srcX: 59,
      srcY: 48,
      srcWidth: 9,
      srcHeight: 44,
      dstX: x,
      dstY: y,
      rotation: rotation - Engine.PI_Quarter,
      scale: 0.7,
    );
  }
}

