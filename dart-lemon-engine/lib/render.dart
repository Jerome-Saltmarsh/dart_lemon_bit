import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:lemon_engine/actions/render_atlas.dart';

var bufferIndex = 0;
var renderIndex = 0;
const bufferSize = 300;
final buffers = bufferSize * 4;
final src = Float32List(buffers);
final dst = Float32List(buffers);
final colors = Int32List(bufferSize);
// final srcFlush = Float32List(4);
// final dstFlush = Float32List(4);
// final colorsFlush = Int32List(1);
var renderBlendMode = BlendMode.dstATop;

void setRenderBlendMode(BlendMode value){
  renderBlendMode = value;
}


void assignCurrentEngineRenderSrcX(double value){
  src[bufferIndex] = value;
}

void engineRender({
  required double srcX,
  required double srcY,
  required double srcWidth,
  required double srcHeight,
  required double dstX,
  required double dstY,
  double dstScale = 1,
  double dstRotation = 0,
  double anchorX = 0.0,
  double anchorY = 0.0,
}) {
  engineRenderSetSrc(
      x: srcX, 
      y: srcY, 
      width: srcWidth, 
      height: srcHeight,
  );
  engineRenderSetDst(
      x: dstX, 
      y: dstY, 
      scale: dstScale, 
      rotation: dstRotation, 
      anchorX: anchorX, 
      anchorY: anchorY,
  );

  renderIndex += 4;
  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;
  renderAtlas();
}

/// If there are draw jobs remaining in the buffer
/// it draws them and clears the rest
void engineRenderFlushBuffer(){
  for (var i = bufferIndex; i < buffers; i += 4) {
    src[i] = 0;
    src[i + 1] = 0;
    src[i + 2] = 0;
    src[i + 3] = 0;
    dst[i] = 0;
    dst[i + 1] = 0;
  }
  bufferIndex = 0;
  renderIndex = 0;
  renderAtlas();
}

void engineRenderSetSrc({
  required double x,
  required double y,
  required double width,
  required double height,
}){
  engineRenderSetSrcX(x);
  engineRenderSetSrcY(y);
  engineRenderSetSrcWidth(width);
  engineRenderSetSrcHeight(width);
}

void engineRenderSetSrcX(double value){
  src[bufferIndex] = value;
}

void engineRenderSetSrcY(double value){
  src[bufferIndex + 1] = value;
}

void engineRenderSetSrcWidth(double value){
  src[bufferIndex + 2] = value;
}

void engineRenderSetSrcHeight(double value){
  src[bufferIndex + 3] = value;
}

/// This function provides significant performance benifits as it 
/// does not need to calculate scale or rotation
void engineRenderSetDstScale1Rotation0({
  required double x,
  required double y,
  required double anchorX,
  required double anchorY,
}){
  // dst[bufferIndex] = x;
  // dst[bufferIndex + 1] = y;
  // dst[bufferIndex + 2] = width;
  // dst[bufferIndex + 3] = height;
}

void engineRenderSetDst({
  required double x,
  required double y,
  required double anchorX,
  required double anchorY,
  double scale = 1.0,
  double rotation = 0.0,
}){
  
}

/// Increments the current buffer index
/// if the buffer is full 
///   the engine performs a render 
///   and resets the buffer to 0
void engineRenderIncrementBufferIndex(){
  bufferIndex += 4;
  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;
  renderAtlas();
}

void renderR({
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

  final double scos = cos(rotation) * scale;
  final double ssin = sin(rotation) * scale;
  final double tx = dstX + -scos * anchorX + ssin * anchorY;
  final double ty = dstY + -ssin * anchorX - scos * anchorY;


  // final scos = cos(rotation) * scale;
  // final ssin = sin(rotation) * scale;

  src[bufferIndex] = srcX;
  dst[bufferIndex] = scos;
  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = ssin;
  bufferIndex++;

  src[bufferIndex] = srcX + srcWidth;
  dst[bufferIndex] = tx;

  bufferIndex++;
  src[bufferIndex] = srcY + srcHeight;
  dst[bufferIndex] = ty;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;

  renderAtlas();
}


final cos0 = cos(0);
final sin0 = sin(0);

void render({
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
  // final scos = cos0 * scale;
  // final ssin = sin0 * scale;

  src[bufferIndex] = srcX;
  dst[bufferIndex] = cos0 * scale;
  colors[renderIndex] = color;
  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = sin0 * scale;
  bufferIndex++;

  src[bufferIndex] = srcX + srcWidth;
  dst[bufferIndex] = dstX - (srcWidth * anchorX * scale);

  bufferIndex++;
  src[bufferIndex] = srcY + srcHeight;
  dst[bufferIndex] = dstY - (srcHeight * anchorY * scale);

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;

  renderAtlas();
}