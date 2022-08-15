
import 'package:gamestream_flutter/isometric/classes/vector3.dart';
import 'package:lemon_engine/render.dart';

void renderCircle32(double x, double y, { double scale = 1.0}){
  render(
      dstX: x,
      dstY: y,
      srcX: 858,
      srcY: 0,
      srcWidth: 32,
      srcHeight: 32,
      scale:  scale,
  );
}

void renderCircleV3(Vector3 value, { double scale = 1.0}){
  render(
    dstX: value.renderX,
    dstY: value.renderY,
    srcX: 858,
    srcY: 0,
    srcWidth: 32,
    srcHeight: 32,
    scale:  scale,
  );
}

void renderCircle({required double x, required double y, required double size}){
     final ratio = size / 32.0;
     render(
       dstX: x,
       dstY: y,
       srcX: 519,
       srcY: 0,
       srcWidth: 32,
       srcHeight: 32,
       scale:  ratio,
     );
}