import 'package:bleed_common/Shade.dart';
import 'package:gamestream_flutter/isometric/classes/particle.dart';
import 'package:gamestream_flutter/isometric/enums/particle_type.dart';
import 'package:lemon_engine/engine.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

void renderParticle(Particle value) {
  switch (value.type) {
    case ParticleType.Smoke:
      return renderSmoke(
          x: value.renderX, y: value.renderY, scale: value.renderScale);
    case ParticleType.Orb_Shard:
      return renderOrbShard(
          x: value.renderX, y: value.renderY, scale: value.renderScale);
    case ParticleType.Shrapnel:
      return renderShrapnel(
          x: value.renderX, y: value.renderY, scale: value.renderScale);
    case ParticleType.FireYellow:
      return renderFireYellow(
          x: value.renderX, y: value.renderY, scale: value.renderScale);
    case ParticleType.Flame:
      return renderFlame(value);
    default:
      break;
  }

  final shade = value.shade;
  if (shade >= Shade.Very_Dark) return;
  // mapParticleToDst(value);
  // mapParticleToSrc(value);
  // engine.renderAtlas();

  if (!value.casteShadow) return;
  if (value.z < 0.1) return;
  renderShadow(position: value, scale: value.z);
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
      srcX: 345,
      srcY: 67,
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
