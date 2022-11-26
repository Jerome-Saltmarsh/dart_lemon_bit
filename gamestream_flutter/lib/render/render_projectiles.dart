

import 'package:gamestream_flutter/isometric/nodes/render/atlas_src_gameobjects.dart';
import 'package:gamestream_flutter/library.dart';

class RenderProjectiles {

  static void renderProjectile(Projectile value) {
    switch (value.type) {
      case ProjectileType.Arrow:
        renderArrow(value.renderX, value.renderY, value.angle);
        return;
      case ProjectileType.Orb:
        // return renderOrb(value.renderX, value.renderY);
        break;
      case ProjectileType.Fireball:
        break;
      case ProjectileType.Bullet:
        renderBullet(value.renderX, value.renderY, value.angle);
        break;
      case ProjectileType.Wave:
        break;
      default:
        return;
    }
  }

  static void renderBullet(double x, double y, double rotation) {
    Engine.renderSpriteRotated(
        image: GameImages.gameobjects,
        srcX: 87,
        srcY: 48,
        srcWidth: 2,
        srcHeight: 32,
        dstX: x,
        dstY: y,
        rotation: rotation - Engine.PI_Quarter,
        scale: 1,
        anchorX: 0.5,
        anchorY: 0,
      );
    // renderPixelRed(x, y);
  }

  static void renderArrow(double x, double y, double rotation) {
    Engine.renderSpriteRotated(
      image: GameImages.gameobjects,
      srcX: AtlasGameObjects.arrow_shadow_x,
      srcY: AtlasGameObjects.arrow_shadow_y,
      srcWidth: AtlasGameObjects.arrow_width,
      srcHeight: AtlasGameObjects.arrow_height,
      dstX: x,
      dstY: y + 10,
      rotation: rotation - Engine.PI_Quarter,
      scale: 0.7,
    );

    Engine.renderSpriteRotated(
      image: GameImages.gameobjects,
      srcX: AtlasGameObjects.arrow_x,
      srcY: AtlasGameObjects.arrow_y,
      srcWidth: AtlasGameObjects.arrow_width,
      srcHeight: AtlasGameObjects.arrow_height,
      dstX: x,
      dstY: y,
      rotation: rotation - Engine.PI_Quarter,
      scale: 0.7,
    );
  }
}