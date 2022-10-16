import 'package:lemon_engine/engine.dart';
import 'package:lemon_math/library.dart';


void renderSmoke({
  required double x,
  required double y,
  required double scale,
}) {
  Engine.renderBuffer(
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
  Engine.renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 2304 ,
      srcY: 256 + (frame % 4) * size,
      srcWidth: size,
      srcHeight: size,
      scale: scale,
  );
}

void renderFlame(Position position) {
  Engine.renderBuffer(
      dstX: position.x,
      dstY: position.y,
      srcY: ((position.x + position.y + Engine.paintFrame) % 6) * 23,
      srcX: 5669,
      srcWidth: 18,
      srcHeight: 23,
      anchorY: 0.9);
}
