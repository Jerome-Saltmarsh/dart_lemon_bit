import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:gamestream_flutter/packages/common/src/particle_type.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_math/src.dart';

class RendererParticles extends RenderGroup {

  late Particle particle;

  var totalActiveParticles = 0;

  @override
  int getTotal() => totalActiveParticles;

  @override
  void reset() {
    particles.sort();
    totalActiveParticles = particles.countActiveParticles;
    super.reset();
  }

  @override
  void renderFunction() {
    final dstX = particle.renderX;
    final dstY = particle.renderY;

      assert (particle.active);
      assert (particle.delay <= 0);
      assert (dstX > engine.Screen_Left - 50);
      assert (dstX < engine.Screen_Right + 50);
      assert (dstY > engine.Screen_Top - 50);
      assert (dstY < engine.Screen_Bottom + 50);

      final particleType = particle.type;

      if (const [
        ParticleType.Blood,
        // ParticleType.Zombie_Head,
        // ParticleType.Zombie_Torso,
        // ParticleType.Zombie_leg,
        // ParticleType.Zombie_Arm,
        ParticleType.Block_Wood,
        ParticleType.Block_Sand,
        ParticleType.Block_Brick,
        ParticleType.Block_Grass,
      ].contains(particleType)){
        render.shadowBelowPosition(particle);
      }

      switch (particleType) {
        case ParticleType.Water_Drop:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 40,
            srcWidth: 4,
            srcHeight: 4,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Blood:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 171,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Smoke:
          renderSmoke();
          break;
        case ParticleType.Myst:
          renderMyst();
          break;
        case ParticleType.Whisp:
          final nodeColor = scene.getColor(particle.nodeIndex);
          final nodeAlpha = getAlpha(nodeColor);
          final perc = ((nodeAlpha / 255) * 4).toInt() * 8;
          engine.renderSprite(
            image: images.atlas_nodes,
            dstX: dstX,
            dstY: dstY,
            srcX: 736,
            srcY: 1848.0 - perc,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
          );
          break;
        case ParticleType.Glow:
          // final nodeColor = scene.getColor(particle.nodeIndex);
          // final nodeAlpha = getAlpha(nodeColor);
          // final perc = ((nodeAlpha / 255) * 4).toInt() * 8;
        final color = colors.aqua_1.value;
          engine.renderSprite(
            image: images.atlas_nodes,
            dstX: dstX,
            dstY: dstY,
            srcX: 976,
            srcY: 1712,
            srcWidth: 48,
            srcHeight: 48,
            scale: particle.emissionIntensity,
            color: color,
          );
          engine.renderSprite(
            image: images.atlas_nodes,
            dstX: dstX,
            dstY: dstY,
            srcX: 976,
            srcY: 1760,
            srcWidth: 48,
            srcHeight: 48,
            scale: particle.emissionIntensity * goldenRatio_0381,
            color: color,
          );
          break;
        case ParticleType.Block_Wood:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 56,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Block_Grass:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 48,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Yellow:
          engine.renderSprite(
            image: images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 216,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Red:
          engine.renderSprite(
            image: images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 192,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bubble_Small:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Bullet_Ring:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Blue:
          engine.renderSprite(
            image: images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 560,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Green:
          engine.renderSprite(
            image: images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 384,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Purple:
          engine.renderSprite(
            image: images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 616,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Confetti_Cyan:
          engine.renderSprite(
            image: images.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 504,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;

        case ParticleType.Block_Brick:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 64,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Gunshot_Smoke:
          if (particle.frame >= 24) {
            particle.deactivate();
            return;
          }
          final frame = particle.frame <= 11 ? particle.frame : 23 - particle.frame;
          engine.renderSprite(
            image: images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 544,
            srcY: 32.0 * frame,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Block_Sand:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 112,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Fire:
          if (particle.frame > 12 ) {
            return particle.deactivate();
          }
          engine.renderSprite(
            image: images.atlas_particles,
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
          renderShell(dstX, dstY);
          break;
        case ParticleType.Fire_Purple:
          if (particle.frame > 24 ) {
            particle.deactivate();
            break;
          }
          engine.renderSprite(
            image: images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 291,
            srcY: 1 + 32.0 * (particle.frame ~/ 2) ,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;

        case ParticleType.Orb_Shard:
          const size = 16.0;
          engine.renderSprite(
            image: images.atlas_gameobjects,
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
          engine.renderSprite(
            image: images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 234.0,
            srcY: 1 + 32.0 + (32.0 * particle.frame),
            srcWidth: 32,
            srcHeight: 32,
          );
          return;
        case ParticleType.Bubble:
          if (particle.duration > 26) {
            particle.deactivate();
            break;
          }
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 8,
            srcHeight: 8,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Zombie_Arm:
          engine.renderSprite(
            image: images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0,
            srcY: 1 + 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Zombie_Head:
          engine.renderSprite(
            image: images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + 64,
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: scene.getRenderColorPosition(particle),
          );
          break;
        case ParticleType.Zombie_leg:
          engine.renderSprite(
            image: images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 2),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: scene.getRenderColorPosition(particle),
          );
          break;

        case ParticleType.Zombie_Torso:
          engine.renderSprite(
            image: images.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 3),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: scene.getRenderColorPosition(particle),
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
          engine.renderSprite(
              image: images.atlas_particles,
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
          engine.renderSprite(
            image: images.atlas_particles,
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

  void renderShell(double dstX, double dstY) {
    engine.renderSprite(
      image: images.atlas_particles,
      dstX: dstX,
      dstY: dstY,
      srcX: particle.direction * 32,
      srcY: 522,
      srcWidth: 32,
      srcHeight: 16,
      scale: 0.25,
      color: scene.getRenderColorPosition(particle),
    );
  }

  void renderSmoke() {

    final totalFrames = 8;
    final frame = ((1.0 - particle.duration01) * totalFrames).round();
    const width = 32.0;
    const height = 32.0;

    engine.renderSpriteRotated(
      image: images.atlas_nodes,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 1584,
      srcY: frame * height,
      srcWidth: width,
      srcHeight: height,
      color: scene.getRenderColorPosition(particle),
      rotation: particle.rotation,
      scale: particle.scale * 0.5,
    );
  }

  void renderMyst() {
    const width = 32.0;
    const height = 32.0;

    final duration = particle.duration01;
    final opacity = 1.0 - (duration < 0.5 ? duration / 0.5 : (1.0 - ((duration - 0.5) / 0.5)));
    final totalFrames = 8;
    final frame = (opacity * totalFrames).round();

    engine.renderSpriteRotated(
      image: images.atlas_nodes,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 1584,
      srcY: frame * height,
      srcWidth: width,
      srcHeight: height,
      color: scene.getRenderColorPosition(particle),
      rotation: particle.rotation,
      scale: particle.scale * 1.5,
    );
  }

  void renderParticleStrikeBlade() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: images.atlas_particles,
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
      color: scene.getRenderColorPosition(particle),
    );
  }

  void renderParticleStrikePunch() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: images.atlas_particles,
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
      color: scene.getRenderColorPosition(particle),
    );
  }

  void renderParticleStrikeBullet() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: images.atlas_particles,
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
      color: scene.getRenderColorPosition(particle),
    );
  }
  void renderParticleStrikeLight() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: images.atlas_particles,
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
      color: scene.getRenderColorPosition(particle),
    );
  }

  @override
  void updateFunction() {
    final minX = engine.Screen_Left - 50;
    final maxX = engine.Screen_Right + 50;
    final minY = engine.Screen_Top - 50;
    final maxY = engine.Screen_Bottom + 50;
    final particles = this.particles.children;

    while (index < total) {
      particle = particles[index++];
      if (particle.delay > 0 || !particle.active) continue;
      final dstX = particle.renderX;
      if (dstX < minX || dstX > maxX) continue;
      final dstY = particle.renderY;
      if (dstY < minY || dstY > maxY) continue;
      if (!scene.isPerceptiblePosition(particle)) continue;
      order = particle.sortOrder;
      index--;
      return;
    }
  }
}
