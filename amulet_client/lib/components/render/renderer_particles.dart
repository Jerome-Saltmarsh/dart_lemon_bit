import 'package:amulet_client/components/isometric_images.dart';
import 'package:amulet_client/components/isometric_particles.dart';
import 'package:amulet_client/functions/generate_colors.dart';
import 'package:amulet_common/src.dart';
import 'package:amulet_client/classes/particle.dart';
import 'package:amulet_client/classes/particle_flying.dart';
import 'package:amulet_client/isometric/ui/isometric_colors.dart';
import 'package:amulet_client/classes/render_group.dart';
import 'package:flutter/material.dart';
import 'package:golden_ratio/constants.dart';
import 'package:lemon_engine/lemon_engine.dart';
import 'package:lemon_math/src.dart';
import 'package:lemon_sprite/lib.dart';

class RendererParticles extends RenderGroup {

  late Particle particle;

  var totalActiveParticles = 0;

  final colorsFlame = generateColorInterpolation4(
      length: IsometricParticles.Flame_Duration,
      colorA: Colors.yellow,
      colorB: Colors.red,
      colorC: Colors.grey,
      colorD: Colors.black12,
  );

  final colorsIce = generateColorInterpolation4(
    length: IsometricParticles.Water_Duration,
    colorA: Palette.blue_4.withOpacity(0.5),
    colorB: Palette.blue_2,
    colorC: Palette.blue_0,
    colorD: Colors.white10,
  );

  final colorsWater = generateColorInterpolation4(
    length: IsometricParticles.Water_Duration,
    colorA: Palette.aqua_1.withOpacity(0.5),
    colorB: Palette.aqua_5,
    colorC: Palette.white,
    colorD: Colors.transparent,
  );

  final colorsHealth = generateColorInterpolation4(
    length: IsometricParticles.Water_Duration,
    colorA: Palette.teal_0.withOpacity(0.5),
    colorB: Palette.teal_2,
    colorC: Palette.teal_4,
    colorD: Colors.transparent,
  );

  final colorsMagic = generateColorInterpolation4(
    length: IsometricParticles.Water_Duration,
    colorA: Palette.blue_0.withOpacity(0.5),
    colorB: Palette.aqua_5,
    colorC: Palette.white,
    colorD: Colors.transparent,
  );

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
                  column: particle.moving ? animation.frameRate3 : 0,
                  mode: AnimationMode.loop,
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
                  column: particle.moving ? animation.frameRate2 % 2 : 0,
                  mode: AnimationMode.loop,
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
                column: particle.moving ? animation.frameRate3: 0,
                mode: AnimationMode.loop,
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
        case ParticleType.Flame:
          renderSquareInterpolation(
            dstX: dstX,
            dstY: dstY,
            colors: colorsFlame,
            i: 1.0 - particle.duration01,
            scale: particle.scale,
          );
          break;
        case ParticleType.Water:
          renderSquareInterpolation(
            dstX: dstX,
            dstY: dstY,
            colors: colorsWater,
            i: 1.0 - particle.duration01,
            scale: particle.scale,
          );
          break;
        case ParticleType.Ice:
          renderSquareInterpolation(
            dstX: dstX,
            dstY: dstY,
            colors: colorsIce,
            i: 1.0 - particle.duration01,
            scale: particle.scale,
          );
          break;
        case ParticleType.Health:
          renderSquareInterpolation(
            dstX: dstX,
            dstY: dstY,
            colors: colorsHealth,
            i: 1.0 - particle.duration01,
            scale: particle.scale,
          );
          break;
        case ParticleType.Magic:
          renderSquareInterpolation(
            dstX: dstX,
            dstY: dstY,
            colors: colorsMagic,
            i: 1.0 - particle.duration01,
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

    void renderSquareInterpolation({
      required double dstX,
      required double dstY,
      required List<Color> colors,
      required double i,
      required double scale,
    }) =>
      renderModulateSquare(
        dstX: dstX,
        dstY: dstY,
        color: colors[(i * colors.length).toInt()].value,
        scale: scale,
      );

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

  void renderModulateSquare({
    required double dstX,
    required double dstY,
    required double scale,
    required int color,
  }){
    final engine = this.engine;
    engine.bufferBlendMode = BlendMode.modulate;
    engine.renderSprite(
      image: images.atlas_nodes,
      dstX: dstX,
      dstY: dstY,
      srcX: 72,
      srcY: 2040,
      srcWidth: 8,
      srcHeight: 8,
      scale: scale,
      color: color,
    );
    engine.setBlendModeDstATop();
  }
}
