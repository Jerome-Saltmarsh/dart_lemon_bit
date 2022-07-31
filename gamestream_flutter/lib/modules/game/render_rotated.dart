import 'dart:math';

import 'package:lemon_engine/actions/render_atlas.dart';
import 'package:lemon_engine/render.dart';
import 'package:lemon_math/library.dart';

void renderRotated({
  required double dstX,
  required double dstY,
  required double srcX,
  required double srcY,
  required double srcWidth,
  required double srcHeight,
  required double rotation,
  double scale = 1.0,
  double anchorX = 0.5,
  double anchorY = 0.5,
  int color = 0,
}){

  final angle = rotation + piQuarter;

  final c = cos(rotation) * scale;
  final s = sin(rotation) * scale;

  final srcWidthHalf = srcWidth * 0.5;
  final srcHeightHalf = srcHeight * 0.5;

  final d = sqrt((srcWidthHalf * srcWidthHalf) + (srcHeightHalf * srcHeightHalf));

  final adj = getAdjacent(angle, d);
  final opp = getOpposite(angle, d);

  src[bufferIndex] = srcX;
  dst[bufferIndex] = c;
  colors[renderIndex] = color;
  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = s;
  bufferIndex++;

  src[bufferIndex] = srcX + srcWidth;
  dst[bufferIndex] = dstX - adj;

  bufferIndex++;
  src[bufferIndex] = srcY + srcHeight;
  dst[bufferIndex] = dstY - opp;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;

  renderAtlas();
}