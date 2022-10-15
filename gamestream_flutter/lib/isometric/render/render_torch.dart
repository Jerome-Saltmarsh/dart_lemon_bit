
import 'package:gamestream_flutter/isometric/animation_frame.dart';
import 'package:lemon_engine/render.dart';

void renderTorchOff(double x, double y) {
  return renderBuffer(
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
  renderBuffer(
      dstX: x,
      dstY: y,
      srcX: 2128,
      srcY: 70 + (((x + y + (animationFrame)) % 6) * 70),
      srcWidth: 25,
      srcHeight: 70,
      anchorY: 0.33
  );
}