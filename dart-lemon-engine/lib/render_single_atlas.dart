
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:lemon_engine/state/paint.dart';

final _src = Float32List(4);
final _dst = Float32List(4);
// final _colors = Int32List(1);
// var blendMode = BlendMode.dstATop;

final _cos0 = cos(0);
final _sin0 = sin(0);

void canvasRenderAtlas({
  required Canvas canvas,
  required Image atlas,
  required double srcX,
  required double srcY,
  required double srcWidth,
  required double srcHeight,
  required double dstX,
  required double dstY,
  double anchorX = 0.5,
  double anchorY = 0.5,
  double scale = 1.0,
  // int color = 1,
}){
  // _colors[0] = color;
  _src[0] = srcX;
  _src[1] = srcY;
  _src[2] = srcX + srcWidth;
  _src[3] = srcY + srcHeight;
  _dst[0] = _cos0 * scale;
  _dst[1] = _sin0 * scale; // scale
  _dst[2] = dstX - (srcWidth * anchorX * scale);
  _dst[3] = dstY - (srcHeight * anchorY * scale); // scale
  canvas.drawRawAtlas(atlas, _dst, _src, null, null, null, paint);
}