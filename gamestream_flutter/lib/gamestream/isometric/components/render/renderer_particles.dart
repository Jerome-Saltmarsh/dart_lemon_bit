import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/classes/position.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/isometric_renderer.dart';
import 'package:gamestream_flutter/gamestream/isometric/isometric.dart';
import 'package:gamestream_flutter/library.dart';

class RendererParticles extends IsometricRenderer {

  late Particle particle;

  var totalActiveParticles = 0;

  RendererParticles(super.isometric);

  @override
  int getTotal() => totalActiveParticles;

  @override
  void reset() {
    isometric.particles.particles.sort(Particle.compare);
    totalActiveParticles = isometric.particles.countActiveParticles;
    super.reset();
  }

  @override
  void renderFunction() {
      assert (particle.active);
      assert (particle.delay <= 0);
      final dstX = Isometric.getPositionRenderX(particle);
      assert (dstX > isometric.engine.Screen_Left - 50);
      assert (dstX < isometric.engine.Screen_Right + 50);
      final dstY = Isometric.getPositionRenderY(particle);
      assert (dstY > isometric.engine.Screen_Top - 50);
      assert (dstY < isometric.engine.Screen_Bottom + 50);

      if (const [
        ParticleType.Blood,
        ParticleType.Zombie_Head,
        ParticleType.Zombie_Torso,
        ParticleType.Zombie_leg,
        ParticleType.Zombie_Arm,
      ].contains(particle.type)){
        isometric.render.renderShadowBelowPosition(particle);
      }

      switch (particle.type) {
        case ParticleType.Water_Drop:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 40,
            srcWidth: 4,
            srcHeight: 4,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Blood:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 171,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bubble:
          if (particle.duration > 26) {
            particle.deactivate();
            break;
          }
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 8,
            srcHeight: 8,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bubble_Small:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bullet_Ring:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: isometric.scene.getRenderColorPosition(particle),
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
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
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
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 56,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Block_Grass:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 48,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Yellow:
          isometric.engine.renderSprite(
            image: isometric.images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 216,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Red:
          isometric.engine.renderSprite(
            image: isometric.images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 192,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Blue:
          isometric.engine.renderSprite(
            image: isometric.images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 560,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Green:
          isometric.engine.renderSprite(
            image: isometric.images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 384,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Purple:
          isometric.engine.renderSprite(
            image: isometric.images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 616,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Cyan:
          isometric.engine.renderSprite(
            image: isometric.images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 504,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;

        case ParticleType.Block_Brick:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 64,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Block_Sand:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 112,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Fire:
          if (particle.frame > 12 ) {
            return particle.deactivate();
          }
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
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
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
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
          isometric.engine.renderSprite(
            image: isometric.images.atlas_gameobjects,
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
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 234.0,
            srcY: 1 + 32.0 + (32.0 * particle.frame),
            srcWidth: 32,
            srcHeight: 32,
          );
          return;
        case ParticleType.Zombie_Arm:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0,
            srcY: 1 + 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Zombie_Head:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + 64,
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Zombie_leg:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 2),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.scene.getRenderColorPosition(particle),
          );
          break;

        case ParticleType.Zombie_Torso:
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 3),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: isometric.scene.getRenderColorPosition(particle),
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
          isometric.engine.renderSprite(
              image: isometric.images.atlas_particles,
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
          isometric.engine.renderSprite(
            image: isometric.images.atlas_particles,
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
    isometric.engine.renderSprite(
      image: isometric.images.atlas_particles,
      dstX: dstX,
      dstY: dstY,
      srcX: particle.direction * 32,
      srcY: 522,
      srcWidth: 32,
      srcHeight: 16,
      scale: 0.25,
      color: isometric.scene.getRenderColorPosition(particle),
    );
  }

  void renderParticleSmoke() {
    // casteShadowDownV3(particle);
    isometric.engine.renderSpriteRotated(
      image: isometric.images.atlas_particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 552,
      srcY: 7,
      srcWidth: 16,
      srcHeight: 16,
      color: isometric.scene.getRenderColorPosition(particle),
      rotation: particle.rotation,
      scale: particle.scale,
    );
  }

  void renderParticleStrikeBlade() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    isometric.engine.renderSpriteRotated(
      image: isometric.images.atlas_particles,
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
      color: isometric.scene.getRenderColorPosition(particle),
    );
  }

  void renderParticleStrikePunch() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    isometric.engine.renderSpriteRotated(
      image: isometric.images.atlas_particles,
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
      color: isometric.scene.getRenderColorPosition(particle),
    );
  }

  void renderParticleStrikeBullet() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    isometric.engine.renderSpriteRotated(
      image: isometric.images.atlas_particles,
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
      color: isometric.scene.getRenderColorPosition(particle),
    );
  }
  void renderParticleStrikeLight() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    isometric.engine.renderSpriteRotated(
      image: isometric.images.atlas_particles,
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
      color: isometric.scene.getRenderColorPosition(particle),
    );
  }

  @override
  void updateFunction() {
    final minX = isometric.engine.Screen_Left - 50;
    final maxX = isometric.engine.Screen_Right + 50;
    final minY = isometric.engine.Screen_Top - 50;
    final maxY = isometric.engine.Screen_Bottom + 50;
    final particles = isometric.particles.particles;

    while (index < total) {
      particle = particles[index++];
      if (particle.delay > 0 || !particle.active) continue;
      final dstX = particle.renderX;
      if (dstX < minX || dstX > maxX) continue;
      final dstY = particle.renderY;
      if (dstY < minY || dstY > maxY) continue;
      if (!isometric.isPerceptiblePosition(particle)) continue;
      order = particle.sortOrder;
      index--;
      return;
    }
  }
}
