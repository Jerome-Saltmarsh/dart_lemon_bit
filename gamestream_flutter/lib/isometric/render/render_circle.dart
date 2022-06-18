
import 'package:lemon_engine/render.dart';

void renderCircle32(double x, double y, { double rotation = 0, double scale = 1.0}){
  renderR(
      dstX: x,
      dstY: y,
      srcX: 519,
      srcY: 0,
      srcWidth: 32,
      srcHeight: 32,
      rotation: rotation,
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