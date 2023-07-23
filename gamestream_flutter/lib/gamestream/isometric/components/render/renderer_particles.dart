import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_particle.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_position.dart';
import 'package:gamestream_flutter/gamestream/isometric/components/isometric_render.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererParticles extends IsometricRenderer {

  late IsometricParticle particle;

  var totalActiveParticles = 0;

  RendererParticles(super.isometric);

  @override
  int getTotal() => totalActiveParticles;

  @override
  void reset() {
    isometric.particles.sort(IsometricParticle.compare);
    totalActiveParticles = isometric.countActiveParticles;
    super.reset();
  }

  @override
  void renderFunction() {
      assert (particle.active);
      assert (particle.delay <= 0);
      final dstX = IsometricRender.getPositionRenderX(particle);
      assert (dstX > isometric.engine.Screen_Left - 50);
      assert (dstX < isometric.engine.Screen_Right + 50);
      final dstY = IsometricRender.getPositionRenderY(particle);
      assert (dstY > isometric.engine.Screen_Top - 50);
      assert (dstY < isometric.engine.Screen_Bottom + 50);

      switch (particle.type) {
        case ParticleType.Water_Drop:
          isometric.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 40,
            srcWidth: 4,
            srcHeight: 4,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Blood:
          casteShadowDownV3(particle);
          isometric.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 171,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bubble:
          if (particle.duration > 26) {
            particle.deactivate();
            break;
          }
          isometric.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 8,
            srcHeight: 8,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bubble_Small:
          isometric.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bullet_Ring:
          gamestream.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Smoke:
          renderParticleSmoke();
          break;
        case ParticleType.Gunshot_Smoke:
          if (particle.frame >= 24) {
            particle.deactivate();
            return;
          }
          final frame = particle.frame <= 11 ? particle.frame : 23 - particle.frame;
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 544,
            srcY: 32.0 * frame,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Block_Wood:
          gamestream.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 56,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Block_Grass:
          gamestream.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 48,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Yellow:
          gamestream.engine.renderSprite(
            image: Images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 216,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Red:
          gamestream.engine.renderSprite(
            image: Images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 192,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Blue:
          gamestream.engine.renderSprite(
            image: Images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 560,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Green:
          gamestream.engine.renderSprite(
            image: Images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 384,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Purple:
          gamestream.engine.renderSprite(
            image: Images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 616,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Cyan:
          gamestream.engine.renderSprite(
            image: Images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 504,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;

        case ParticleType.Block_Brick:
          gamestream.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 64,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Block_Sand:
          gamestream.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 112,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Fire:
          if (particle.frame > 12 ) {
            return particle.deactivate();
          }
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 32.0 * particle.frame,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Shell:
          renderParticleShell(dstX, dstY);
          break;
        case ParticleType.Fire_Purple:
          if (particle.frame > 24 ) {
            particle.deactivate();
            break;
          }
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 291,
            srcY: 1 + 32.0 * (particle.frame ~/ 2) ,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Myst:
          // const size = 48.0;
          // final shade = GameState.getV3RenderShade(particle);
          // if (shade >= 5) return;
          // engine.renderSprite(
          //   image: GameImages.particles,
          //   dstX: particle.renderX,
          //   dstY: particle.renderY,
          //   srcX: 480 ,
          //   srcY: shade * size,
          //   srcWidth: size,
          //   srcHeight: size,
          //   scale: particle.scale,
          //   color: 1,
          // );
          break;
        case ParticleType.Orb_Shard:
          const size = 16.0;
          gamestream.engine.renderSprite(
            image: Images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 224 ,
            srcY: (particle.frame % 4) * size,
            srcWidth: size,
            srcHeight: size,
            scale: particle.scale,
          );
          break;
        case ParticleType.Star_Explosion:
          if (particle.frame >= 7) {
            return particle.deactivate();
          }
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 234.0,
            srcY: 1 + 32.0 + (32.0 * particle.frame),
            srcWidth: 32,
            srcHeight: 32,
          );
          return;
        case ParticleType.Zombie_Arm:
          casteShadowDownV3(particle);
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0,
            srcY: 1 + 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Zombie_Head:
          casteShadowDownV3(particle);
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + 64,
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Zombie_leg:
          casteShadowDownV3(particle);
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 2),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.getRenderColorPosition(particle),
          );
          break;

        case ParticleType.Zombie_Torso:
          casteShadowDownV3(particle);
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 3),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Strike_Blade:
          renderParticleStrikeBlade();
          break;
        case ParticleType.Strike_Punch:
          renderParticleStrikePunch();
          break;
        case ParticleType.Strike_Bullet:
          renderParticleStrikeBullet();
          break;
        case ParticleType.Strike_Light:
          renderParticleStrikeLight();
          break;
        case ParticleType.Shadow:
          gamestream.engine.renderSprite(
              image: Images.atlas_particles,
              srcX: 8,
              srcY: 552,
              srcWidth: 16,
              srcHeight: 16,
              dstX: dstX,
              dstY: dstY,
              scale: 0.5,
          );
          break;
        case ParticleType.Lightning_Bolt:
          gamestream.engine.renderSprite(
            image: Images.atlas_particles,
            srcX: 1,
            srcY: 576,
            srcWidth: 51,
            srcHeight: 90,
            dstX: dstX,
            dstY: dstY,
            scale: 1.0,
            anchorY: 1.0,
          );
          break;
        default:
          break;
      }
    }

  void renderParticleShell(double dstX, double dstY) {
    gamestream.engine.renderSprite(
      image: Images.atlas_particles,
      dstX: dstX,
      dstY: dstY,
      srcX: particle.direction * 32,
      srcY: 522,
      srcWidth: 32,
      srcHeight: 16,
      scale: 0.25,
      color: isometric.getRenderColorPosition(particle),
    );
  }

  void renderParticleSmoke() {
    // casteShadowDownV3(particle);
    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 552,
      srcY: 7,
      srcWidth: 16,
      srcHeight: 16,
      color: isometric.getRenderColorPosition(particle),
      rotation: particle.rotation,
      scale: particle.scale,
    );
  }

  void renderParticleStrikeBlade() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 688,
      srcY: 1 + particle.frame * 61,
      srcWidth: 84,
      srcHeight: 61,
      scale: particle.scale,
      rotation: particle.rotation + piQuarter + piHalf,
      anchorX: 0.5,
      anchorY: 0.1,
      color: isometric.getRenderColorPosition(particle),
    );
  }

  void renderParticleStrikePunch() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 592,
      srcY: particle.frame * 47,
      srcWidth: 31,
      srcHeight: 47,
      scale: particle.scale,
      rotation: particle.rotation + piQuarter + piHalf,
      anchorX: 0.4,
      anchorY: 0.1,
      color: isometric.getRenderColorPosition(particle),
    );
  }

  void renderParticleStrikeBullet() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 624,
      srcY: particle.frame * 47,
      srcWidth: 31,
      srcHeight: 47,
      scale: particle.scale,
      rotation: particle.rotation + piQuarter + piHalf,
      anchorX: 0.5,
      anchorY: 0.1,
      color: isometric.getRenderColorPosition(particle),
    );
  }
  void renderParticleStrikeLight() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    gamestream.engine.renderSpriteRotated(
      image: Images.atlas_particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 656,
      srcY: particle.frame * 47,
      srcWidth: 31,
      srcHeight: 47,
      scale: particle.scale,
      rotation: particle.rotation + piQuarter + piHalf,
      anchorX: 0.5,
      anchorY: 0.1,
      color: isometric.getRenderColorPosition(particle),
    );
  }

  @override
  void updateFunction() {
    while (index < total) {
      particle = isometric.particles[index++];
      if (particle.delay > 0) continue;
      if (!particle.active) continue;
      final dstX = particle.renderX;
      if (dstX < gamestream.engine.Screen_Left - 50) continue;
      if (dstX > gamestream.engine.Screen_Right + 50) continue;
      final dstY = particle.renderY;
      if (dstY < gamestream.engine.Screen_Top - 50) continue;
      if (dstY > gamestream.engine.Screen_Bottom + 50) continue;
      if (!isometric.isPerceptiblePosition(particle)) continue;

      // orderZ = particle.indexZ;
      order = particle.sortOrder;
      index--;
      return;
    }
  }

  void casteShadowDownV3(IsometricPosition vector3){
    if (vector3.z < Node_Height) return;
    if (vector3.z >= isometric.lengthZ) return;
    final nodeIndex = isometric.getIndexPosition(vector3);
    if (nodeIndex > isometric.area) {
      final nodeBelowIndex = nodeIndex - isometric.area;
      final nodeBelowOrientation = isometric.nodeOrientations[nodeBelowIndex];
      if (nodeBelowOrientation == NodeOrientation.Solid){
        final topRemainder = vector3.z % Node_Height;
        isometric.renderShadow(vector3.x, vector3.y, vector3.z - topRemainder, scale: topRemainder > 0 ? (topRemainder / Node_Height) * 2 : 2.0);
      }
    }
  }
}
