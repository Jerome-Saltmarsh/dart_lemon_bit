
import 'package:gamestream_flutter/library.dart';

void renderCircle32(double x, double y, { double scale = 1.0}){
  Engine.renderSprite(
    image: GameImages.gameobjects,
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
  Engine.renderSprite(
    image: GameImages.gameobjects,
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
     Engine.renderSprite(
       image: GameImages.gameobjects,
       dstX: x,
       dstY: y,
       srcX: 519,
       srcY: 0,
       srcWidth: 32,
       srcHeight: 32,
       scale:  ratio,
     );
}