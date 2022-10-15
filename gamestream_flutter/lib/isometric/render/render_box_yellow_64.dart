
import 'package:lemon_engine/engine.dart';

void renderBoxYellow64(double x, double y){
  Engine.renderBuffer(
    dstX: x,
    dstY: y,
    srcX: 560,
    srcY: 0,
    srcWidth: 64,
    srcHeight: 64,
    scale: 0.7,
  );
}