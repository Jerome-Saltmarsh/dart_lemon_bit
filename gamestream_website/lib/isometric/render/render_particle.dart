import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

void renderParticle(Particle value) {
  switch (value.type) {
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
      return renderOrbShard(
          x: value.renderX,
          y: value.renderY,
          scale: value.scale,
      );
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
}) {
  render(
      dstX: x,
      dstY: y,
      srcX: 616,
      srcY: 0,
      srcWidth: 8,
      srcHeight: 8,
      scale: scale
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
