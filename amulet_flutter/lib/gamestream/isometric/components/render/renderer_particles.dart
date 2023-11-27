import 'package:amulet_flutter/functions/get_alpha.dart';
import 'package:amulet_flutter/gamestream/isometric/classes/particle_flying.dart';
import 'package:amulet_flutter/gamestream/isometric/classes/render_group.dart';
import 'package:amulet_flutter/gamestream/isometric/components/isometric_images.dart';
import 'package:amulet_flutter/isometric/classes/particle.dart';
import 'package:amulet_flutter/packages/common.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
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
  void renderFunction(LemonEngine engine, IsometricImages images) {
    final particle = this.particle;
    final dstX = particle.renderX;
    final dstY = particle.renderY;

    assert(particle.onscreen);

    if (particle.delay > 0) {
      return;
    }

    final particleType = particle.type;

      if (const [
        ParticleType.Blood,
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
            srcWidth: 3,
            srcHeight: 3,
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
          renderMyst(particle, scale: 0.5);
          break;
        case ParticleType.Myst:
          renderMyst(particle);
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
        final color = particle.emissionColor;
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
        case ParticleType.Butterfly:
          final sprite = images.butterfly;

          if (particle is ParticleFlying){
            final direction = IsometricDirection.fromRadian(particle.rotation);
            render.sprite(
              sprite: sprite,
              frame: sprite.getFrame(
                  row: IsometricDirection.toInputDirection(direction),
                  column: particle.moving ? animation.frame1 % 2 : 0,
              ),
              color: scene.getColor(particle.nodeIndex), // TODO Optimize
              scale: 0.2,
              dstX: dstX,
              dstY: dstY,
            );
          }
          break;
        case ParticleType.Moth:
          if (particle is ParticleFlying){
            final sprite = images.moth;
            final direction = IsometricDirection.fromRadian(particle.rotation);
            render.sprite(
              sprite: sprite,
              frame: sprite.getFrame(
                  row: IsometricDirection.toInputDirection(direction),
                  column: particle.moving ? animation.frame1 % 2 : 0,
              ),
              color: scene.getColor(particle.nodeIndex), // TODO Optimize
              scale: 0.1,
              dstX: dstX,
              dstY: dstY,
            );
          }
          break;
        case ParticleType.Bat:
          final sprite = images.bat;
          if (particle is ParticleFlying){
            final direction = IsometricDirection.fromRadian(particle.rotation);
            render.sprite(
              sprite: sprite,
              frame: sprite.getFrame(
                row: IsometricDirection.toInputDirection(direction),
                column: particle.moving ? animation.frame1: 0,
              ),
              color: scene.getColor(particle.nodeIndex),
              scale: 0.2,
              dstX: dstX,
              dstY: dstY,
            );
          }
          break;
        case ParticleType.Wind:
          engine.renderSprite(
              image: images.atlas_nodes,
              srcX: 72,
              srcY: 2040,
              srcWidth: 8,
              srcHeight: 8,
              dstX: dstX,
              dstY: dstY,
          );
          break;
        case ParticleType.Trail:
          final duration01 = particle.duration01;
          final frame = getFrame(duration01, 7);
          engine.renderSprite(
            image: images.atlas_nodes,
            dstX: dstX,
            dstY: dstY,
            srcX: 736,
            srcY: 1864 - (frame * 8),
            srcWidth: 8,
            srcHeight: 8,
            scale: 0.5 * (duration01),
            color: particle.emissionColor,
          );
          break;
        case ParticleType.Water_Drop_Large:
          engine.renderSprite(
            image: images.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 40,
            srcWidth: 1,
            srcHeight: 3,
            color: scene.getRenderColorPosition(particle),
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
        case ParticleType.Confetti:
          engine.renderSprite(
            image: images.shadesTransparent,
            dstX: dstX,
            dstY: dstY,
            srcX: 864,
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
        case ParticleType.Shadow:
          engine.renderSprite(
              image: images.atlas_particles,
              srcX: 8,
              srcY: 552,
              srcWidth: 16,
              srcHeight: 16,
              dstX: dstX,
              dstY: dstY,
              scale: particle.scale,
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

  void renderMyst(Particle particle, {double scale = 1.0}) {
    const size = 64.0;
    const totalFrames = 9;

    final duration01 = particle.duration01;
    final opacity = 1.0 - (duration01 < 0.5 ? duration01 / 0.5 : (1.0 - ((duration01 - 0.5) / 0.5)));
    final frame = (opacity * totalFrames).round();

    engine.renderSprite(
      image: images.atlas_nodes,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 656 + (frame * size),
      srcY: 1600,
      srcWidth: size,
      srcHeight: size,
      color: scene.getRenderColorPosition(particle),
      scale: particle.scale * scale,
    );
  }

  @override
  void updateFunction() {

    final particles = this.particles.activated;
    final total = this.total;

    var index = this.index;

    while (index < total) {
      final particle = particles[index++];

      if (!particle.onscreen)
        continue;

      this.particle = particle;
      order = particle.sortOrder;
      index--;
      this.index = index;
      return;
    }
    this.index = index;
  }

  static int getFrame(double percentage, int total) => ((1.0 - percentage) * total).round();
}
