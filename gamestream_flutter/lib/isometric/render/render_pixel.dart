
import 'package:lemon_engine/render.dart';

import '../classes/vector3.dart';

void renderPixelRedV2(Vector3 value){
  renderPixelRed(value.renderX, value.renderY);
}

void renderPixelRed(double x, double y){
  render(
    dstX: x,
    dstY: y,
    srcX: 144,
    srcY: 0 ,
    srcWidth: 8,
    srcHeight: 8,
    anchorX: 0.5,
    anchorY: 0.5
  );
}
