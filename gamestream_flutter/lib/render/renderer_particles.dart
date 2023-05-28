import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererParticles extends Renderer {

  static final particles = gamestream.games.isometric.clientState2.particles;
  static late Particle particle;
  static final screen = engine.screen;

  @override
  void renderFunction() {
      assert (particle.active);
      assert (particle.delay <= 0);
      final dstX = GameConvert.convertV3ToRenderX(particle);
      assert (dstX > engine.Screen_Left - 50);
      assert (dstX < engine.Screen_Right + 50);
      final dstY = GameConvert.convertV3ToRenderY(particle);
      assert (dstY > engine.Screen_Top - 50);
      assert (dstY < engine.Screen_Bottom + 50);

      switch (particle.type) {
        case ParticleType.Water_Drop:
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 40,
            srcWidth: 4,
            srcHeight: 4,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Blood:
          casteShadowDownV3(particle);
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: AtlasParticleX.Blood,
            srcY: AtlasParticleY.Blood,
            srcWidth: 8,
            srcHeight: 8,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Bubble:
          if (particle.duration > 26) {
            particle.deactivate();
            break;
          }
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 8,
            srcHeight: 8,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Bubble_Small:
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Bullet_Ring:
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
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
          engine.renderSprite(
            image: GameImages.atlas_particles,
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
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 56,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Block_Grass:
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 48,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Confetti_Yellow:
          engine.renderSprite(
            image: GameImages.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 216,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Confetti_Red:
          engine.renderSprite(
            image: GameImages.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 192,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Confetti_Blue:
          engine.renderSprite(
            image: GameImages.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 560,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Confetti_Green:
          engine.renderSprite(
            image: GameImages.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 384,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Confetti_Purple:
          engine.renderSprite(
            image: GameImages.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 616,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Confetti_Cyan:
          engine.renderSprite(
            image: GameImages.shades,
            dstX: dstX,
            dstY: dstY,
            srcX: 504,
            srcY: 0,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;

        case ParticleType.Block_Brick:
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 64,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Block_Sand:
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: dstX,
            dstY: dstY,
            srcX: 0,
            srcY: 112,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Fire:
          if (particle.frame > 12 ) {
            return particle.deactivate();
          }
          engine.renderSprite(
            image: GameImages.atlas_particles,
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
          engine.renderSprite(
            image: GameImages.atlas_particles,
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
          engine.renderSprite(
            image: GameImages.atlas_gameobjects,
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
            image: GameImages.atlas_particles,
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
          engine.renderSprite(
            image: GameImages.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0,
            srcY: 1 + 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Zombie_Head:
          casteShadowDownV3(particle);
          engine.renderSprite(
            image: GameImages.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + 64,
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Zombie_leg:
          casteShadowDownV3(particle);
          engine.renderSprite(
            image: GameImages.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 2),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
          );
          break;

        case ParticleType.Zombie_Torso:
          casteShadowDownV3(particle);
          engine.renderSprite(
            image: GameImages.atlas_particles,
            dstX: dstX,
            dstY: dstY,
            srcX: 34.0 + (64 * 3),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
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
              image: GameImages.atlas_particles,
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
            image: GameImages.atlas_particles,
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
    engine.renderSprite(
      image: GameImages.atlas_particles,
      dstX: dstX,
      dstY: dstY,
      srcX: particle.direction * 32,
      srcY: 522,
      srcWidth: 32,
      srcHeight: 16,
      scale: 0.25,
      color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
    );
  }

  void renderParticleSmoke() {
    // casteShadowDownV3(particle);
    engine.renderSpriteRotated(
      image: GameImages.atlas_particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 552,
      srcY: 7,
      srcWidth: 16,
      srcHeight: 16,
      color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
      rotation: particle.rotation,
      scale: particle.scale,
    );
  }

  static void renderParticleStrikeBlade() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: GameImages.atlas_particles,
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
      color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
    );
  }

  static void renderParticleStrikePunch() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: GameImages.atlas_particles,
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
      color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
    );
  }

  static void renderParticleStrikeBullet() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: GameImages.atlas_particles,
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
      color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
    );
  }
  static void renderParticleStrikeLight() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    engine.renderSpriteRotated(
      image: GameImages.atlas_particles,
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
      color: gamestream.games.isometric.clientState.getV3RenderColor(particle),
    );
  }

  @override
  void updateFunction() {
    while (index < total) {
      particle = particles[index++];
      if (particle.delay > 0) continue;
      if (!particle.active) continue;
      final dstX = GameConvert.convertV3ToRenderX(particle);
      if (dstX < engine.Screen_Left - 50) continue;
      if (dstX > engine.Screen_Right + 50) continue;
      final dstY = GameConvert.convertV3ToRenderY(particle);
      if (dstY < engine.Screen_Top - 50) continue;
      if (dstY > engine.Screen_Bottom + 50) continue;
      if (!particle.nodePerceptible) continue;

      orderZ = particle.indexZ;
      orderRowColumn = particle.indexSum;
      index--;
      return;
    }
  }

  @override
  int getTotal() => gamestream.games.isometric.clientState2.totalParticles;

  @override
  void reset() {
    gamestream.games.isometric.clientState2.sortParticles();
    super.reset();
  }

  static void casteShadowDownV3(Vector3 vector3){
    if (vector3.z < Node_Height) return;
    if (vector3.z >= gamestream.games.isometric.nodes.lengthZ) return;
    final nodeIndex = gamestream.games.isometric.nodes.getNodeIndexV3(vector3);
    if (nodeIndex > gamestream.games.isometric.nodes.area) {
      final nodeBelowIndex = nodeIndex - gamestream.games.isometric.nodes.area;
      final nodeBelowOrientation = gamestream.games.isometric.nodes.nodeOrientations[nodeBelowIndex];
      if (nodeBelowOrientation == NodeOrientation.Solid){
        final topRemainder = vector3.z % Node_Height;
        renderShadow(vector3.x, vector3.y, vector3.z - topRemainder, scale: topRemainder > 0 ? (topRemainder / Node_Height) * 2 : 2.0);
      }
    }
  }
}
