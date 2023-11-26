import 'package:lemon_engine/actions/render_atlas.dart';
import 'package:lemon_engine/render.dart';


var _dstX = 0.0;
var _dstY = 0.0;
var _shade = 0;
var transparent = false;

// void renderGridNode(int z, int row, int column, int type, double dstY, int shade) {
//   _dstX = (row - column) * tileSizeHalf;
//   if (_dstX < screen.left) return;
//   if (_dstX > screen.right) return;
//   _dstY = dstY;
//   _shade = shade;
//
//   switch (type) {
//     case GridNodeType.Bricks:
//       return renderBlockSrcX(7110);
//     case GridNodeType.Grass:
//       switch (gridWind[z][row][column]) {
//         case windIndexCalm:
//           return renderBlockSrcX(5267);
//         default:
//           return renderBlockSrcX(5267 + ((((row - column) + animationFrameGrassShort) % 6) * 48));
//       }
//
//     case GridNodeType.Grass_Slope_North:
//       return renderBlockSrcX(7925);
//     case GridNodeType.Grass_Slope_East:
//       return renderBlockSrcX(7877);
//     case GridNodeType.Grass_Slope_South:
//       return renderBlockSrcX(7829);
//     case GridNodeType.Grass_Slope_West:
//       return renderBlockSrcX(7781);
//
//     case GridNodeType.Grass_Slope_Top:
//       return renderBlockSrcX(8536);
//
//     case GridNodeType.Grass_Slope_Right:
//       return renderBlockSrcX(8488);
//
//     case GridNodeType.Grass_Slope_Bottom:
//       return renderBlockSrcX(8440);
//
//     case GridNodeType.Grass_Slope_Left:
//       return renderBlockSrcX(8392);
//
//     case GridNodeType.Grass_Long:
//       switch (gridWind[z][row][column]) {
//         case windIndexCalm:
//           return renderBlockSrcX(4856);
//         case windIndexGentle:
//           return renderBlockSrcX(4856 + ((((row - column) + animationFrameGrass) % 4) * 48));
//          default:
//            return renderBlockSrcX(5048 + ((((row - column) + animationFrameGrass) % 4) * 48));
//       }
//
//     case GridNodeType.Rain_Falling:
//       return render(
//         dstX: _dstX - rainPosition,
//         dstY: dstY + animationFrameRain,
//         srcX: srcXRainFalling,
//         srcY: 72.0 * animationFrameRain,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//         color: colorShades[shade],
//       );
//
//     case GridNodeType.Rain_Landing:
//       return render(
//         dstX: _dstX,
//         dstY: dstY,
//         srcX: srcXRainLanding,
//         srcY: 72.0 * animationFrameRain,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//         color: colorShades[shade],
//       );
//     case GridNodeType.Wood:
//       return renderBlockSrcX(8887);
//     case GridNodeType.Soil:
//       return renderBlockSrcX(8320);
//     case GridNodeType.Roof_Tile_North:
//       return renderBlockSrcX(9415);
//     case GridNodeType.Roof_Tile_South:
//       return renderBlockSrcX(9463);
//     case GridNodeType.Stairs_South:
//       return renderBlockSrcX(7398);
//     case GridNodeType.Stairs_West:
//       return renderBlockSrcX(7446);
//     case GridNodeType.Stairs_North:
//       return renderBlockSrcX(7494);
//     case GridNodeType.Stairs_East:
//       return renderBlockSrcX(7542);
//     case GridNodeType.Brick_Top:
//       return renderBlockSrcX(8621);
//     case GridNodeType.Wood_Half_Row_1:
//       return renderBlockSrcX(8935);
//     case GridNodeType.Wood_Half_Row_2:
//       _dstX += 16;
//       _dstY -= 16;
//       return renderBlockSrcX(8935);
//     case GridNodeType.Wood_Half_Column_1:
//       return renderBlockSrcX(8983);
//     case GridNodeType.Wood_Half_Column_2:
//       _dstX -= 16;
//       _dstY -= 16;
//       return renderBlockSrcX(8983);
//     case GridNodeType.Wood_Corner_Bottom:
//       return renderBlockSrcX(9175);
//     case GridNodeType.Wood_Corner_Left:
//       return renderBlockSrcX(9031);
//     case GridNodeType.Wood_Corner_Top:
//       return renderBlockSrcX(9079);
//     case GridNodeType.Wood_Corner_Right:
//       return renderBlockSrcX(9127);
//     case GridNodeType.Water:
//       return render(
//         dstX: _dstX,
//         dstY: dstY + animationFrameWaterHeight,
//         srcX: 7206 + animationFrameWaterSrcX,
//         srcY: 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Water_Flowing:
//       return render(
//         dstX: _dstX,
//         dstY: dstY + animationFrameWaterHeight,
//         srcX: 8096 + animationFrameWaterSrcX,
//         srcY: 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Stone:
//       return renderBlockSrcX(9831);
//     case GridNodeType.Torch:
//       if (!torchesIgnited.value) {
//         return renderTorchOff(_dstX, dstY);
//       }
//       final wind = gridWind[z][row][column];
//
//       if (wind == Wind.Calm){
//         return renderTorchOn(_dstX, dstY);
//       }
//       return renderTorchOnWindy(_dstX, dstY);
//
//     case GridNodeType.Tree_Bottom:
//       return render(
//         dstX: _dstX,
//         dstY: dstY,
//         srcX: 1478,
//         srcY: 74.0 * shade,
//         srcWidth: 62.0,
//         srcHeight: 74.0,
//         anchorY: 0.5,
//       );
//     case GridNodeType.Tree_Top:
//       final wind = gridWind[z][row][column];
//       animationFrameTreePosition = treeAnimation[(row - column + animationFrame) % treeAnimation.length] * wind;
//       return render(
//         dstX: _dstX + (animationFrameTreePosition * 0.5),
//         dstY: dstY,
//         srcX: 1540,
//         srcY: 74.0 * shade,
//         srcWidth: 62.0,
//         srcHeight: 74.0,
//         anchorY: 0.5,
//       );
//
//     case GridNodeType.Fireplace:
//       return render(
//         dstX: _dstX,
//         dstY: dstY,
//         srcX: 6469,
//         srcY: (((row + column + (animationFrameTorch)) % 6) * 72),
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Player_Spawn:
//       return render(
//         dstX: _dstX,
//         dstY: dstY,
//         srcX: 7686,
//         srcY: 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Enemy_Spawn:
//       if (!playModeEdit) return;
//       return render(
//         dstX: _dstX,
//         dstY: dstY,
//         srcX: 7686,
//         srcY: 72.0 * shade,
//         srcWidth: 48,
//         srcHeight: 72,
//         anchorY: 0.3334,
//       );
//     case GridNodeType.Roof_Hay_North:
//       return renderBlockSrcX(9552);
//     case GridNodeType.Roof_Hay_South:
//       return renderBlockSrcX(9600);
//     default:
//       throw Exception("Cannot render grid node type $type");
//   }
// }

void renderBlockSrcX(double srcX){

  const spriteWidth = 48.0;
  const spriteHeight = 72.0;
  const spriteWidthHalf = 24.0;
  const spriteHeightThird = 24.0;

  var srcY = _shade * spriteHeight;

  if (transparent){
    srcY += 432;
  }

  src[bufferIndex] = srcX;
  dst[bufferIndex] = 1;
  colors[renderIndex] = 0;

  bufferIndex++;

  src[bufferIndex] = srcY;
  dst[bufferIndex] = 0;

  bufferIndex++;

  src[bufferIndex] = srcX + spriteWidth;
  dst[bufferIndex] = _dstX - spriteWidthHalf;

  bufferIndex++;

  src[bufferIndex] = srcY + spriteHeight;
  dst[bufferIndex] = _dstY - spriteHeightThird;

  bufferIndex++;
  renderIndex++;

  if (bufferIndex < buffers) return;
  bufferIndex = 0;
  renderIndex = 0;
  renderAtlas();
}

