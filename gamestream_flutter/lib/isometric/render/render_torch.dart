
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:lemon_engine/engine.dart';

void renderTorchOff(double x, double y) {
  return Engine.renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 2086,
      srcY: 0,
      srcWidth: 25,
      srcHeight: 70,
      anchorY: 0.33
  );
}

void renderTorchOnWindy(double x, double y) {
  Engine.renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 2128,
      srcY: 70 + (((x + y + (animationFrame)) % 6) * 70),
      srcWidth: 25,
      srcHeight: 70,
      anchorY: 0.33
  );
}