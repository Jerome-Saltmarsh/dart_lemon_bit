
import 'package:lemon_engine/render.dart';

void renderShadow(double x, double y, double z, {double scale = 1}) =>
   render(
    dstX: (x - y) * 0.5,
    dstY: ((y + x) * 0.5) - z,
    srcX: 192,
    srcY: 0,
    srcWidth: 8,
    srcHeight: 8,
    scale: scale,
  );

