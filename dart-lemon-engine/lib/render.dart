import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:lemon_engine/engine.dart';

var bufferIndex = 0;
var bufferBlendMode = BlendMode.dstATop;
const bufferSize = 100;
final bufferSrc = Float32List(bufferSize * 4);
final bufferDst = Float32List(bufferSize * 4);
final bufferColors = Int32List(bufferSize);


/// If there are draw jobs remaining in the buffer
/// it draws them and clears the rest
void engineRenderFlushBuffer() {
  if (bufferIndex == 0) return;
  while (bufferIndex < bufferSize) {
    bufferSrc[bufferIndex] = 0;
    bufferDst[bufferIndex] = 0;
    bufferSrc[bufferIndex + 1] = 0;
    bufferDst[bufferIndex + 1] = 0;
    bufferSrc[bufferIndex + 2] = 0;
    bufferSrc[bufferIndex + 3] = 0;
    bufferIndex++;
  }
  _internalRenderBuffer();
}

void renderBufferRotated({
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
}){
  final scos = cos(rotation) * scale;
  final ssin = sin(rotation) * scale;
  final tx = dstX + -scos * anchorX + ssin * anchorY;
  final ty = dstY + -ssin * anchorX - scos * anchorY;
  final i = bufferIndex * 4;
  bufferSrc[i] = srcX;
  bufferDst[i] = scos;
  bufferSrc[i + 1] = srcY;
  bufferDst[i + 1] = ssin;
  bufferSrc[i + 2] = srcX + srcWidth;
  bufferDst[i + 2] = tx;
  bufferSrc[i + 3] = srcY + srcHeight;
  bufferDst[i + 3] = ty;
  _internalIncrementBufferIndex();
}

void renderBuffer({
  required double dstX,
  required double dstY,
  required double srcX,
  required double srcY,
  required double srcWidth,
  required double srcHeight,
  double scale = 1.0,
  double anchorX = 0.5,
  double anchorY = 0.5,
  int color = 0,
}){
  final i = bufferIndex * 4;
  bufferColors[bufferIndex] = color;
  bufferSrc[i] = srcX;
  bufferDst[i] = scale;
  bufferSrc[i + 1] = srcY;
  bufferDst[i + 1] = 0;
  bufferSrc[i + 2] = srcX + srcWidth;
  bufferDst[i + 2] = dstX - (srcWidth * anchorX * scale);
  bufferSrc[i + 3] = srcY + srcHeight;
  bufferDst[i + 3] = dstY - (srcHeight * anchorY * scale);
  _internalIncrementBufferIndex();
}

void _internalIncrementBufferIndex(){
  bufferIndex++;
  if (bufferIndex >= bufferSize)
    _internalRenderBuffer();
}

void _internalRenderBuffer(){
  bufferIndex = 0;
  Engine.canvas.drawRawAtlas(Engine.atlas, bufferDst, bufferSrc, bufferColors, bufferBlendMode, null, Engine.paint);
}