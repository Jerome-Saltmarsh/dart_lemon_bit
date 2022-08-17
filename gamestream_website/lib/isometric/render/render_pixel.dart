
import 'package:lemon_engine/render.dart';

void renderPixelRed(double x, double y){
  render(
    dstX: x,
    dstY: y,
    srcX: 97,
    srcY: 25,
    srcWidth: 8,
    srcHeight: 8,
    anchorX: 0.5,
    anchorY: 0.5
  );
}