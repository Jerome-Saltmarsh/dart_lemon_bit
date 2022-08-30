import 'package:lemon_engine/actions/render_atlas.dart';
import 'package:lemon_engine/render.dart';

import 'render_node.dart';

/// Renders a standard size block from the atlas
/// The standard dimension of a block is 48 x 72
void renderAtlasStandardNode({
  required int z,
  required int row,
  required int column,
  required double srcX,
  required double srcY,
              int color = 0,
}) {
  const spriteWidth = 48.0;
  const spriteHeight = 72.0;
  const spriteWidthHalf = spriteWidth * 0.5;
  const spriteHeightThird = 24.0;

  src[bufferIndex] = srcX;
  dst[bufferIndex] = 1;
  colors[renderIndex] = color;

  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = 0;

  bufferIndex++;

  src[bufferIndex] = srcX + spriteWidth;
  dst[bufferIndex] = projectX(row, column) - spriteWidthHalf;

  bufferIndex++;

  src[bufferIndex] = srcY + spriteHeight;
  dst[bufferIndex] = projectY(row, column, z) - spriteHeightThird;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;
  renderAtlas();
}
