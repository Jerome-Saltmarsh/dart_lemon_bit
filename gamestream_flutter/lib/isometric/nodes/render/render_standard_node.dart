
import 'package:gamestream_flutter/isometric/render/render_sprites.dart';
import 'package:lemon_engine/actions/render_atlas.dart';
import 'package:lemon_engine/render.dart';

import 'render_constants.dart';

void renderStandardNode({
  required double srcX,
  required double srcY,
  int color = 1,
}){

  colors[renderIndex] = color;

  src[bufferIndex] = srcX;
  dst[bufferIndex] = 1;
  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = 0;
  bufferIndex++;

  src[bufferIndex] = srcX + spriteWidth;
  dst[bufferIndex] = renderNodeDstX - spriteWidthHalf;

  bufferIndex++;
  src[bufferIndex] = srcY + spriteHeight;
  dst[bufferIndex] = renderNodeDstY - spriteHeightThird;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;

  renderAtlas();
}
