import 'package:gamestream_flutter/library.dart';

import 'functions/render_shadow.dart';

class RendererParticles extends Renderer {

  static late Particle particle;

  @override
  void renderFunction() {
      assert (particle.active);
      if (particle.delay > 0) return;
      switch (particle.type) {
        case ParticleType.Water_Drop:
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: GameConvert.convertV3ToRenderX(particle),
            dstY: GameConvert.convertV3ToRenderY(particle),
            srcX: 0.0,
            srcY: 40,
            srcWidth: 4,
            srcHeight: 4,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Blood:
          casteShadowDownV3(particle);
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: AtlasParticleX.Blood,
            srcY: AtlasParticleY.Blood,
            srcWidth: 8,
            srcHeight: 8,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Bubble:
          if (particle.duration > 26) {
            particle.deactivate();
            break;
          }
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: GameConvert.convertV3ToRenderX(particle),
            dstY: GameConvert.convertV3ToRenderY(particle),
            srcX: 0.0,
            srcY: 32,
            srcWidth: 8,
            srcHeight: 8,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Bubble_Small:
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: GameConvert.convertV3ToRenderX(particle),
            dstY: GameConvert.convertV3ToRenderY(particle),
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Bullet_Ring:
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: GameConvert.convertV3ToRenderX(particle),
            dstY: GameConvert.convertV3ToRenderY(particle),
            srcX: 0.0,
            srcY: 32,
            srcWidth: 4,
            srcHeight: 4,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Smoke:
          if (particle.frame >= 24) {
            particle.deactivate();
            return;
          }
          final frame = particle.frame <= 11 ? particle.frame : 23 - particle.frame;

          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 432,
            srcY: 32.0 * frame,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Gunshot_Smoke:
          if (particle.frame >= 24) {
            particle.deactivate();
            return;
          }
          final frame = particle.frame <= 11 ? particle.frame : 23 - particle.frame;
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 544,
            srcY: 32.0 * frame,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Block_Wood:
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 0,
            srcY: 56,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Block_Grass:
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 0,
            srcY: 48,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Block_Brick:
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 0,
            srcY: 64,
            srcWidth: 8,
            srcHeight: 8,
            scale: particle.scale,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Fire:
          if (particle.frame > 12 ) {
            return particle.deactivate();
          }
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 0,
            srcY: 32.0 * particle.frame,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Shell:
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 34 + (particle.direction * 32),
            srcY: 1,
            srcWidth: 32,
            srcHeight: 32,
            scale: 0.25,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Fire_Purple:
          if (particle.frame > 24 ) {
            particle.deactivate();
            break;
          }
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 291,
            srcY: 1 + 32.0 * (particle.frame ~/ 2) ,
            srcWidth: 32,
            srcHeight: 32,
            scale: particle.scale,
          );
          break;
        case ParticleType.Myst:
          const size = 48.0;
          // final shade = GameState.getV3RenderShade(particle);
          // if (shade >= 5) return;
          // Engine.renderSprite(
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
          Engine.renderSprite(
            image: GameImages.atlas_gameobjects,
            dstX: particle.renderX,
            dstY: particle.renderY,
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
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 234.0,
            srcY: 1 + 32.0 + (32.0 * particle.frame),
            srcWidth: 32,
            srcHeight: 32,
          );
          return;
        case ParticleType.Zombie_Arm:
          casteShadowDownV3(particle);
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 34.0,
            srcY: 1 + 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Zombie_Head:
          casteShadowDownV3(particle);
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 34.0 + 64,
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Zombie_leg:
          casteShadowDownV3(particle);
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 34.0 + (64 * 2),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: GameState.getV3RenderColor(particle),
          );
          break;

        case ParticleType.Character_Animation_Dog_Death:
          final frame = capIndex(const [1, 1, 6, 6, 7], particle.frame);

          Engine.renderSprite(
            image: GameImages.character_dog,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 64.0 * frame,
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: GameState.getV3RenderColor(particle),
          );
          break;

        case ParticleType.Zombie_Torso:
          casteShadowDownV3(particle);
          Engine.renderSprite(
            image: GameImages.particles,
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 34.0 + (64 * 3),
            srcY: 64.0 * particle.direction,
            srcWidth: 64,
            srcHeight: 64,
            color: GameState.getV3RenderColor(particle),
          );
          break;
        case ParticleType.Strike_Blade:
          renderParticleStrikeBlade();
          break;
        case ParticleType.Strike_Punch:
          renderParticleStrikePunch();
          break;
        default:
          break;
      }
    }

  static void renderParticleStrikeBlade() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    const size = 64.0;
    Engine.renderSpriteRotated(
      image: GameImages.particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 357,
      srcY: 1 + particle.frame * size,
      srcWidth: size,
      srcHeight: size,
      scale: particle.scale,
      rotation: particle.rotation + piQuarter + piHalf,
      anchorX: 0.5,
      anchorY: 0.0,
    );
  }

  static void renderParticleStrikePunch() {
    if (particle.frame >= 6 ) {
      particle.deactivate();
      return;
    }
    Engine.renderSpriteRotated(
      image: GameImages.particles,
      dstX: particle.renderX,
      dstY: particle.renderY,
      srcX: 592,
      srcY: particle.frame * 47,
      srcWidth: 31,
      srcHeight: 47,
      scale: particle.scale,
      rotation: particle.rotation + piQuarter + piHalf,
      anchorX: 0.5,
      anchorY: 0.0,
    );
  }


  @override
  void updateFunction() {
    particle = ClientState.particles[index];
    order = particle.renderOrder;
    orderZ = particle.indexZ;
  }

  @override
  int getTotal() => ClientState.totalActiveParticles;

  @override
  void reset() {
    ClientState.sortParticles();
    super.reset();
  }

  static void casteShadowDownV3(Vector3 vector3){
    if (vector3.z < Node_Height) return;
    if (vector3.z >= GameState.nodesLengthZ) return;
    final nodeIndex = GameQueries.getNodeIndexV3(vector3);
    if (nodeIndex > GameNodes.area) {
      final nodeBelowIndex = nodeIndex - GameNodes.area;
      final nodeBelowOrientation = GameNodes.nodeOrientations[nodeBelowIndex];
      if (nodeBelowOrientation == NodeOrientation.Solid){
        final topRemainder = vector3.z % Node_Height;
        renderShadow(vector3.x, vector3.y, vector3.z - topRemainder, scale: topRemainder > 0 ? (topRemainder / Node_Height) * 2 : 2.0);
      }
    }
  }
}
