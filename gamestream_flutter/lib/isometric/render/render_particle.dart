import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:gamestream_flutter/modules/game/render_rotated.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

void renderParticle(Particle value) {
  switch (value.type) {

    case ParticleType.Bubble:
      if (value.duration < 26){
        const size = 32.0;
        final frame = (26 - value.duration) ~/ 2;
        return render(
            dstX: value.renderX,
            dstY: value.renderY,
            srcX: 2896.0,
            srcY: frame * size,
            srcWidth: size,
            srcHeight: size,
            color: value.renderColor
        );
      }

      const size = 8.0;
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 2864.0,
          srcY: ((value.frame ~/ 2) % 6) * size,
          srcWidth: size,
          srcHeight: size,
          color: value.renderColor
      );

    case ParticleType.Bubble_Small:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 2976.0,
          srcY: ((value.frame ~/ 2) % 6) * 5,
          srcWidth: 4,
          srcHeight: 5,
          color: value.renderColor
      );

    case ParticleType.Bullet_Ring:
      final frame = value.frame ~/ 2;
      if (frame > 6) return;
      const size = 32.0;
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 2544,
        srcY: frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: value.scale,
        color: value.renderColor,
      );

    case ParticleType.Water_Drop:
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 48,
        srcY: 8,
        srcWidth: 3,
        srcHeight: 3,
        scale: value.scale,
        color: value.renderColor,
      );

    case ParticleType.Smoke:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 5612,
          srcY: 0,
          srcWidth: 50,
          srcHeight: 50,
          scale: value.scale,
          color: value.renderColor,
      );

    case ParticleType.Block_Wood:
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 1760,
        srcY: 48,
        srcWidth: 16,
        srcHeight: 16,
        scale: value.scale,
        color: value.renderColor,
      );

    case ParticleType.Block_Grass:
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 1760,
        srcY: 64,
        srcWidth: 16,
        srcHeight: 16,
        scale: value.scale,
        color: value.renderColor,
      );

    case ParticleType.Block_Brick:
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 1760,
        srcY: 80,
        srcWidth: 16,
        srcHeight: 16,
        scale: value.scale,
        color: value.renderColor,
      );

    case ParticleType.Fire:
      if (value.frame > 12 ) return;
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 4464,
        srcY: 32.0 * value.frame ,
        srcWidth: 32,
        srcHeight: 32,
        scale: value.scale,
      );

    case ParticleType.Fire_Purple:
      if (value.frame > 24 ) return;
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 6032,
        srcY: 32.0 * (value.frame ~/ 2) ,
        srcWidth: 32,
        srcHeight: 32,
        scale: value.scale,
      );
    case ParticleType.Blood:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 184,
          srcY: 0,
          srcWidth: 8,
          srcHeight: 8,
          color: value.renderColor
      );
    case ParticleType.Orb_Shard:
      renderOrbShard(
          x: value.renderX,
          y: value.renderY,
          scale: value.scale,
          rotation: value.rotation,
          frame: value.frame,
      );
      return;
    case ParticleType.Shrapnel:
      return renderShrapnel(
          x: value.renderX,
          y: value.renderY,
          scale: value.scale,
      );
    case ParticleType.FireYellow:
      return renderFireYellow(
          x: value.renderX, y: value.renderY, scale: value.scale);
    case ParticleType.Flame:
      return renderFlame(value);

    case ParticleType.Zombie_Arm:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 4030.0,
          srcY: 64.0 * value.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: value.renderColor
      );

    case ParticleType.Star_Explosion:
      if (value.frame >= 7) {
        return value.deactivate();
      }
      render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 2304.0,
          srcY: 32.0 + (32.0 * value.frame),
          srcWidth: 32,
          srcHeight: 32,
      );
      return;

    case ParticleType.Zombie_Head:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 4030.0 + 64,
          srcY: 64.0 * value.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: value.renderColor
      );

    case ParticleType.Cut_Grass:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 2928,
          srcY: 0,
          srcWidth: 32,
          srcHeight: 32,
          color: value.renderColor
      );

    case ParticleType.Zombie_leg:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 4030.0 + (64 * 2),
          srcY: 64.0 * value.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: value.renderColor
      );

    case ParticleType.Zombie_Torso:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 4030.0 + (64 * 3),
          srcY: 64.0 * value.direction,
          srcWidth: 64,
          srcHeight: 64,
          color: value.renderColor
      );
    case ParticleType.Leaf:
      return render(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 281.0,
          srcY: 25,
          srcWidth: 8,
          srcHeight: 8,
          color: value.renderColor
      );

    case ParticleType.Dust:
      if (value.frame >= 8 ) return;
      const size = 32.0;
      return render(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 2832,
        srcY: value.frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: value.scale,
      );

    case ParticleType.Handgun_Firing:
      return renderRotated(
          dstX: value.renderX,
          dstY: value.renderY,
          srcX: 2640,
          srcY: 0,
          srcWidth: 16,
          srcHeight: 16,
          rotation: value.rotation + (piHalf + piQuarter),
      );

    case ParticleType.Slash:
      if (value.frame >= 6 ) return;
      const size = 64.0;
      return renderRotated(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 6080,
        srcY: value.frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: value.scale,
        rotation: value.rotation + (piHalf + piQuarter),
      );

    case ParticleType.Slash_Crowbar:
      if (value.frame >= 3 ) {
        return particleDeactivate(value);
      }
      const size = 64.0;
      return renderRotated(
        dstX: value.renderX,
        dstY: value.renderY,
        srcX: 784,
        srcY: value.frame * size,
        srcWidth: size,
        srcHeight: size,
        scale: value.scale,
        rotation: value.rotation + (piHalf + piQuarter),
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
  render(
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
  render(
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
  render(
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
  render(
      dstX: x,
      dstY: y,
      srcX: 145,
      srcY: 25,
      srcWidth: 8,
      srcHeight: 8,
      scale: scale);
}

void renderFlame(Position position) {
  render(
      dstX: position.x,
      dstY: position.y,
      srcY: ((position.x + position.y + engine.frame) % 6) * 23,
      srcX: 5669,
      srcWidth: 18,
      srcHeight: 23,
      anchorY: 0.9);
}

void renderShadow({
  required Position position,
  required double scale,
}) {
  // mapShadeShadow();
  // engine.mapDst(
  //   x: position.x,
  //   y: position.y,
  //   anchorX: 4.0,
  //   anchorY: 4.0,
  //   scale: scale,
  // );
  // engine.renderAtlas();
}

void mapShadeShadow() {
  // engine.mapSrc(x: 1, y: 34, width: 8.0, height: 8.0);
}
