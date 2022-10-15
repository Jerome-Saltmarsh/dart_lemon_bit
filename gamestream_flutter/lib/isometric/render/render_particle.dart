import 'package:bleed_common/particle_type.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/modules/game/render_rotated.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

import 'get_character_render_color.dart';
import 'render_shadow_v3.dart';

void renderParticle(Particle particle) {
  switch (particle.type) {

    case ParticleType.Bubble:
      if (particle.duration < 26){
        const size = 32.0;
        final frame = (26 - particle.duration) ~/ 2;
        return renderBuffer(
            dstX: particle.renderX,
            dstY: particle.renderY,
            srcX: 2896.0,
            srcY: frame * size,
            srcWidth: size,
            srcHeight: size,
            color: getRenderColor(particle),
        );
      }

      const size = 8.0;
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 2864.0,
          srcY: ((particle.frame ~/ 2) % 6) * size,
          srcWidth: size,
          srcHeight: size,
          color: getRenderColor(particle),
      );

    case ParticleType.Bubble_Small:
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 2976.0,
          srcY: ((particle.frame ~/ 2) % 6) * 5,
          srcWidth: 4,
          srcHeight: 5,
          color: getRenderColor(particle),
      );

    case ParticleType.Bullet_Ring:
      final frame = particle.frame ~/ 2;
      if (frame > 6) return;
      const size = 32.0;
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 2544,
        srcY: frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: particle.scale,
        color: getRenderColor(particle),
      );

    case ParticleType.Water_Drop:
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 48,
        srcY: 8,
        srcWidth: 3,
        srcHeight: 3,
        scale: particle.scale,
        color: getRenderColor(particle),
      );

    case ParticleType.Smoke:
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 5612,
          srcY: 0,
          srcWidth: 50,
          srcHeight: 50,
          scale: particle.scale,
          color: getRenderColor(particle),
      );

    case ParticleType.Block_Wood:
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 1760,
        srcY: 48,
        srcWidth: 16,
        srcHeight: 16,
        scale: particle.scale,
        color: getRenderColor(particle),
      );

    case ParticleType.Block_Grass:
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 1760,
        srcY: 64,
        srcWidth: 16,
        srcHeight: 16,
        scale: particle.scale,
        color: getRenderColor(particle),
      );

    case ParticleType.Block_Brick:
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 1760,
        srcY: 80,
        srcWidth: 16,
        srcHeight: 16,
        scale: particle.scale,
        color: getRenderColor(particle),
      );

    case ParticleType.Fire:
      if (particle.frame > 12 ) {
        return particleDeactivate(particle);
      }
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 4464,
        srcY: 32.0 * particle.frame ,
        srcWidth: 32,
        srcHeight: 32,
        scale: particle.scale,
      );

    case ParticleType.Shell:
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 1008 + (particle.direction * 32),
        srcY: 0,
        srcWidth: 32,
        srcHeight: 32,
        scale: 0.25,
        color: getRenderColor(particle),
      );

    case ParticleType.Fire_Purple:
      if (particle.frame > 24 ) {
        return particleDeactivate(particle);
      }
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 6032,
        srcY: 32.0 * (particle.frame ~/ 2) ,
        srcWidth: 32,
        srcHeight: 32,
        scale: particle.scale,
      );
    case ParticleType.Blood:
       casteShadowDownV3(particle);

      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 16,
          srcY: 25,
          srcWidth: 8,
          srcHeight: 8,
          color: getRenderColor(particle),
      );
    case ParticleType.Orb_Shard:
      renderOrbShard(
          x: particle.renderX,
          y: particle.renderY,
          scale: particle.scale,
          rotation: particle.rotation,
          frame: particle.frame,
      );
      return;
    case ParticleType.Shrapnel:
      return renderShrapnel(
          x: particle.renderX,
          y: particle.renderY,
          scale: particle.scale,
      );
    case ParticleType.Flame:
      return renderFlame(particle);

    case ParticleType.Zombie_Arm:

      casteShadowDownV3(particle);

      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 4030.0,
          srcY: 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: getRenderColor(particle),
      );

    case ParticleType.Star_Explosion:
      if (particle.frame >= 7) {
        return particle.deactivate();
      }
      renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 2304.0,
          srcY: 32.0 + (32.0 * particle.frame),
          srcWidth: 32,
          srcHeight: 32,
      );
      return;

    case ParticleType.Zombie_Head:

      casteShadowDownV3(particle);
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 4030.0 + 64,
          srcY: 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: getRenderColor(particle),
      );

    case ParticleType.Cut_Grass:
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 2928,
          srcY: 0,
          srcWidth: 32,
          srcHeight: 32,
          color: getRenderColor(particle),
      );

    case ParticleType.Zombie_leg:

      casteShadowDownV3(particle);
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 4030.0 + (64 * 2),
          srcY: 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: getRenderColor(particle),
      );

    case ParticleType.Zombie_Torso:

      casteShadowDownV3(particle);
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 4030.0 + (64 * 3),
          srcY: 64.0 * particle.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: getRenderColor(particle),
      );
    case ParticleType.Leaf:
      return renderBuffer(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 281.0,
          srcY: 25,
          srcWidth: 8,
          srcHeight: 8,
          color: getRenderColor(particle),
      );

    case ParticleType.Dust:
      if (particle.frame >= 8 ) return;
      const size = 32.0;
      return renderBuffer(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 2832,
        srcY: particle.frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: particle.scale,
      );

    case ParticleType.Handgun_Firing:
      return renderRotated(
          dstX: particle.renderX,
          dstY: particle.renderY,
          srcX: 2640,
          srcY: 0,
          srcWidth: 16,
          srcHeight: 16,
          rotation: particle.rotation + (piHalf + piQuarter),
      );

    case ParticleType.Strike_Blade:
      if (particle.frame >= 6 ) {
         return particleDeactivate(particle);
      }
      const size = 64.0;
      casteShadowDownV3(particle);
      return renderRotated(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 6080,
        srcY: particle.frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: particle.scale,
        rotation: particle.rotation + (piHalf + piQuarter),
      );

    case ParticleType.Strike_Punch:
      if (particle.frame >= 3 ) return;
      const size = 32.0;
      casteShadowDownV3(particle);
      return renderRotated(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 6272 ,
        srcY: 32 + particle.frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: particle.scale,
        rotation: particle.rotation + (piHalf + piQuarter),
      );

    case ParticleType.Slash_Crowbar:
      if (particle.frame >= 3 ) {
        return particleDeactivate(particle);
      }
      const size = 64.0;
      return renderRotated(
        dstX: particle.renderX,
        dstY: particle.renderY,
        srcX: 784,
        srcY: particle.frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: particle.scale,
        rotation: particle.rotation + (piHalf + piQuarter),
      );

    default:
      break;
  }
}

void renderSmoke({
  required double x,
  required double y,
  required double scale,
}) {
  renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 5612,
      srcY: 0,
      srcWidth: 50,
      srcHeight: 50,
      scale: scale);
}

void renderOrbShard({
  required double x,
  required double y,
  required double scale,
  required double rotation,
  required int frame,
}) {
  const size = 16.0;
  renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 2304 ,
      srcY: 256 + (frame % 4) * size,
      srcWidth: size,
      srcHeight: size,
      scale: scale,
  );
}

void renderShrapnel({
  required double x,
  required double y,
  double scale = 1.0,
}) {
  renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 1,
      srcY: 1,
      srcWidth: 8,
      srcHeight: 8,
      scale: scale
  );
}

void renderFireYellow({
  required double x,
  required double y,
  double scale = 1.0,
}) {
  renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 145,
      srcY: 25,
      srcWidth: 8,
      srcHeight: 8,
      scale: scale);
}

void renderFlame(Position position) {
  renderBuffer(
      dstX: position.x,
      dstY: position.y,
      srcY: ((position.x + position.y + Engine.paintFrame) % 6) * 23,
      srcX: 5669,
      srcWidth: 18,
      srcHeight: 23,
      anchorY: 0.9);
}
